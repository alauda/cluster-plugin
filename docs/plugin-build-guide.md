# 从 Helm Chart 构建 ACP 插件指南

本文档面向已有 Helm chart 的开发者，指导如何将 chart 构造并打包为一个 ACP 集群插件。

## 前提条件

- 已有一个可正常部署的 Helm chart
- chart 已推送到 OCI 镜像仓库（如 Harbor）
- 已下载 violet CLI 工具（[下载地址](#下载-violet)）

## 准备插件目录结构

在已有 chart 的基础上，需要新增两个文件：chart 根目录的 `module-plugin.yaml` 和 `scripts/plugin-config.yaml`，并确保 `values.yaml` 中的镜像声明符合规范。

最终目录结构如下：

```
your-chart/
├── Chart.yaml
├── module-plugin.yaml          # 新增：插件声明
├── scripts/
│   └── plugin-config.yaml      # 新增：插件配置
├── values.yaml                 # 需调整：镜像声明格式
└── templates/
    └── ...                     # 已有的 Helm 模板
```

## 第一步：编写 module-plugin.yaml

在 chart 根目录创建 `module-plugin.yaml`，声明插件的基本信息。

### 最小化示例

```yaml
kind: ModulePlugin
metadata:
  annotations:
    cpaas.io/built-in-plugin: "false"
    cpaas.io/display-name: '{"en": "My Plugin", "zh": "我的插件"}'
    cpaas.io/module-name: my-plugin
  labels:
    cpaas.io/module-name: my-plugin
    cpaas.io/module-type: plugin
    cpaas.io/product: devops
  name: my-plugin
spec:
  appReleases:
  - chartVersions:
    - name: <registry>/<chart-name>    # OCI chart 地址
      releaseName: <release-name>
      version: v1.0.0
    name: my-plugin
  deleteable: true
  description:
    en: My plugin description
    zh: 我的插件描述
  logo: data:image/svg+xml;base64,<base64-svg-data>
  mainChart: <registry>/<chart-name>   # 与 chartVersions[0].name 一致
  name: my-plugin
```

### 必填字段说明

| 字段 | 说明 |
|------|------|
| `metadata.annotations.cpaas.io/built-in-plugin` | 固定为 `"false"`（非内置插件） |
| `metadata.annotations.cpaas.io/display-name` | 插件显示名称，JSON 格式包含中英文 |
| `metadata.annotations.cpaas.io/module-name` | 插件名称 |
| `metadata.labels.cpaas.io/module-name` | 插件名称，与 annotation 保持一致 |
| `metadata.labels.cpaas.io/module-type` | 固定为 `plugin` |
| `metadata.labels.cpaas.io/product` | 所属产品分类 |
| `metadata.name` | 插件名称 |
| `spec.appReleases` | chart 列表，包含 chart 地址、release 名称和版本 |
| `spec.deleteable` | 插件是否可删除 |
| `spec.description` | 插件功能描述（中英文） |
| `spec.logo` | 插件 logo，base64 编码的 SVG（可用 [vecta.io/nano](https://vecta.io/nano) 压缩） |
| `spec.mainChart` | 主 chart 的 OCI 地址 |
| `spec.name` | 插件名称 |

### 可选字段

- `metadata.labels.cpaas.io/module-catalog` — 插件分类
- `spec.affinity` — 部署限制（如互斥插件）
- `spec.dependencies` — 依赖插件列表
- `spec.deleteRiskDescription` / `spec.deleteRiskDescriptionEn` — 删除风险提示
- `spec.upgradeRiskDescription` / `spec.upgradeRiskDescriptionEn` — 升级风险提示
- `spec.upgradeRiskLevel` — 升级风险等级（`low` / `middle` / `high`）
- `spec.resourcesBlockRemove` — 阻止删除插件的资源列表

完整字段说明参考 [ModulePlugin 配置说明](moduleplugin.md)。

## 第二步：编写 scripts/plugin-config.yaml

在 chart 根目录下创建 `scripts/` 目录，并在其中创建 `plugin-config.yaml`。**即使插件没有可配置项，也必须有这个文件。**

### 无配置项场景（最小配置）

```yaml
supportedUpgradeVersions: ">= v1.0.0"
mustUpgrade: false
config: {}
valuesTemplates:
```

字段说明：

| 字段 | 说明 |
|------|------|
| `supportedUpgradeVersions` | 支持从哪些旧版本升级，使用 [semver range](https://github.com/blang/semver) 语法 |
| `mustUpgrade` | 升级条件不满足时，是否阻塞集群统一升级 |
| `config` | 动态表单的默认值，无配置项时为 `{}` |
| `valuesTemplates` | chart 值模板，部署时由插件中心渲染 |

### 有配置项场景

如果插件需要用户在部署时填写配置，需要同时设置 `config`、`valuesTemplates` 和 `deployDescriptors`：

```yaml
supportedUpgradeVersions: ">= v1.0.0"
mustUpgrade: false
config:
  replicas: 2
  enableFeatureX: true
valuesTemplates:
  <registry>/<chart-name>: |
    replicaCount: << .MiConfig.replicas >>
    featureX:
      enabled: << .MiConfig.enableFeatureX >>
deployDescriptors:
- name: replicas
  type: number
  label:
    en: Replicas
    zh: 副本数
  default: 2
- name: enableFeatureX
  type: boolean
  label:
    en: Enable Feature X
    zh: 启用功能 X
  default: true
```

> **注意：** `valuesTemplates` 中的 key 必须与 `module-plugin.yaml` 中 `spec.appReleases[].chartVersions[].name` 一致。模板语法使用 `<<` `>>` 作为分隔符，`.MiConfig` 引用 `config` 中定义的字段。

完整配置说明参考 [scripts/plugin-config.yaml 配置说明](scriptspluginconfig.md)。

## 第三步：规范 values.yaml 中的镜像声明

插件使用的所有容器镜像必须在 `values.yaml` 中按以下格式声明：

```yaml
global:
  images:
    <image-name>:
      repository: <repo-path>       # 镜像仓库路径
      tag: <version>                 # 镜像版本
      support_arm: true              # 是否支持 ARM 架构
      thirdparty: true               # 是否为三方镜像
```

示例：

```yaml
global:
  images:
    kubectl:
      repository: 3rdparty/kubectl
      tag: v1.31.2
      support_arm: true
      thirdparty: true
    my-app:
      repository: my-org/my-app
      tag: v1.0.0
      support_arm: false
      thirdparty: false
```

`<image-name>` 可自定义命名。violet 打包时会根据此清单自动导出镜像。

## 第四步：使用 violet 打包

### 下载 violet

violet CLI 工具请通过线下渠道获取，支持 Linux (x86_64/ARM64)、macOS (x86_64/ARM64) 和 Windows (x86_64) 平台。

### 1. 初始化插件

```shell
violet create <plugin-name> \
  --artifact <OCI-chart-address> \
  --platforms linux/amd64 \
  --username <registry-username> \
  --password <registry-password>
```

参数说明：

| 参数 | 必填 | 说明 |
|------|------|------|
| `<plugin-name>` | 是 | 插件名称 |
| `--artifact` | 是 | OCI chart 仓库地址 |
| `--platforms` | 否 | 目标架构，默认 `linux/amd64`。支持 ARM 时使用 `linux/amd64,linux/arm64` |
| `--username` | 否 | 镜像仓库用户名，`--no-auth` 为 false 才生效 |
| `--password` | 否 | 镜像仓库密码，`--no-auth` 为 false 才生效 |
| `--plain` | 否 | 镜像仓库使用 HTTP（非 HTTPS）时指定 |
| `--no-auth` | 否 | 是否禁用镜像仓库鉴权，默认 `false` |
| `--module-plugin` | 否 | 指定 ModulePlugin YAML 文件路径。优先级高于 chart 中的 module-plugin.yaml    |

### 2. 打包插件

```shell
violet package <plugin-name> \
  --username <registry-username> \
  --password <registry-password>
```

执行后在当前目录生成 `<plugin-name>.tgz` 文件。

| 参数 | 必填 | 说明 |
|------|------|------|
| `<plugin-name>` | 是 | 插件名称（与 create 时一致） |
| `--username` | 否 | 镜像仓库用户名，`--no-auth` 为 false 才生效 |
| `--password` | 否 | 镜像仓库密码，`--no-auth` 为 false 才生效 |
| `--plain` | 否 | 镜像仓库使用 HTTP 时指定 |
| `--no-auth` | 否 | 是否禁用镜像仓库鉴权，默认 `false` |

### 3. 上架插件

```shell
violet push <plugin-name>.tgz \
  --platform-address <ACP-address> \
  --platform-username <ACP-username> \
  --platform-password <ACP-password>
```

| 参数 | 必填 | 说明 |
|------|------|------|
| `<plugin-name>.tgz` | 是 | 打包生成的文件 |
| `--platform-address` | 是 | ACP 平台地址 |
| `--platform-username` | 是 | ACP 平台登录用户名 |
| `--platform-password` | 是 | ACP 平台登录密码 |

## 第五步：部署验证

插件上架后，在 ACP 平台上验证部署：

1. 进入**平台管理** → **集群管理** → **集群**
2. 选择需要安装插件的目标集群
3. 点击**插件**标签页
4. 找到已上架的插件，点击**部署**
5. 如有配置项，填写配置参数后确认部署

卸载路径相同，在插件页面点击**卸载**即可。

## 完整示例

项目中提供了完整的插件样例，包含上述所有文件，可作为参考：

[sample/chart](../sample/chart)
