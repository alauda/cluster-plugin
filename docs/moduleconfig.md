
# ModuleConfig 配置说明
ModuleConfig CR 是由 ModulePlugin 自动创建的。该资源不需要人工配置。
```yaml
apiVersion: cluster.alauda.io/v1alpha1
kind: ModuleConfig
metadata:
  annotations:
    cpaas.io/built-in-plugin: "true"  # 标识为未拆包的插件
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}'  # 显示名称
    cpaas.io/module-name: test-plugin  # 插件名称
  finalizers:
    - moduleconfig
  labels:
    cpaas.io/module-catalog: devops # 所属产品
    cpaas.io/module-name: test-plugin # 插件名称
    cpaas.io/module-type: plugin  # 固定字段
    cpaas.io/module-version: v0.0.1  # 插件的版本
    cpaas.io/product: ACP # 插件所属产品
  name: test-plugin-v0.0.1 # ModuleConfig CR 名称
spec:
  # 可选， 插件的部署限制, 仅当有限制时填写
  affinity:
    pluginAntiAffinity:
      - test-plugin
  appReleases:
    - chartVersions:
      - name: ait/test-plugin
        releaseName: test-plugin
        version: v0.0.1
      name: test-plugin
  config: # 可选，插件配置，数据来源于主 chart 的 scripts/plugin-config.yaml
    self:
      storage:
        disabled: true
  deleteRiskDescription: 中文 # 可选，删除插件风险提示中文文案
  deleteRiskDescriptionEn: English # 可选，删除插件风险提示英文文案
  deleteable: true # 插件是否可以删除
  dependencies: # 可选，插件依赖的模块，在部署或升级时必须等依赖的模块运行正常后才可操作当前插件
    - moduleName: base
      versionsMatch:
        - '*'
  # 可选，插件动态表单 descriptors 配置
  deployDescriptors:
    # 这里将 spec.config.self.storage.disabled 定义为一个开关，默认值 false。
    # 该开关值也可以被 spec.valuesTemplates 引用，并最终渲染到插件的 chart 中。
    - description: ""
      path: self.storage.disabled
      x-descriptors:
        - urn:alm:descriptor:com.tectonic.ui:booleanSwitch
        - urn:alm:descriptor:com.tectonic.default:false
  # 可选，valuesTemplates 定义了各个 chart 的配置模板，在创建或更新 AppRelease 时会将这部分数据渲染并填充到 chart 中
  valuesTemplates:
    ait/test-plugin:
      global:
        # .MiConfig 是一个固定值，表示当前配置的 spec.config
        storageEnabled: .MiConfig.self.storage.disabled
  mainChart: ait/test-plugin  # 主 chart, 存放有插件配置项 scripts/plugin-config.yaml
  name: test-plugin # 插件名称
  supportedUpgradeVersions: '>= v1.0.0' # 插件可以支持从哪个旧版本升级
  targetClusterVersions: # 可选，插件可部署的集群 ACP 版本
    - v3.16.0-alpha.595
  # 可选，插件前端 UI 配置
  uiContext:
    sizeSettings:
      quotaTip: {}
  upgradeRiskDescription: 中文 # 可选，插件升级风险提示中文文案
  upgradeRiskDescriptionEn: English # 可选，插件升级风险提示英文文文案
  upgradeRiskLevel: low # 可选，插件升级风险等级，可取值：low, middle, high
  version: v0.0.1 # 当前 ModuleConfig 版本
```

-------------
| 字段                            | 说明                                                                                                                                                                                                                                                                                                                                  | 必选 |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----|
| spec.appReleases              | 将 chart 组织成 apprelease 形式由 sentry 安装,　apprelease 会被并行安装                                                                                                                                                                                                                                                                             | 是  |
| spec.deleteable               | 插件是否可删除                                                                                                                                                                                                                                                                                                                             | 是  |
| spec.description              | 插件的中英文描述                                                                                                                                                                                                                                                                                                                            | 是  |
| spec.logo                     | logo 为 base64 后的 svg 数据，在线压缩svg工具: https://vecta.io/nano                                                                                                                                                                                                                                                                            | 是  |
| spec.mainChart                | 主 chart, 存放有插件配置项 scripts/plugin-config.yaml                                                                                                                                                                                                                                                                                        | 是  |
| spec.name                     | 插件名称                                                                                                                                                                                                                                                                                                                                | 是  |
| spec.supportedUpgradeVersions | 插件可以支持从哪个旧版本升级                                                                                                                                                                                                                                                                                                                      | 是  |
| spec.version                  | 当前 ModuleConfig 版本                                                                                                                                                                                                                                                                                                                  | 是  |
| spec.upgradeRiskDescription   | 插件的升级说明                                                                                                                                                                                                                                                                                                                             | 否  |
| spec.upgradeRiskLevel         | 插件的升级风险等级，可取值：low, middle, high                                                                                                                                                                                                                                                                                                     | 否  |
| spec.affinity                 | 插件亲和配置。亲和类型有 clusterAffinity、clusterAntiAffinity 和 pluginAntiAffinity 三类。<br/>1. clusterAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 能够匹配 matchLabels 的标签，则插件可以部署； <br/>2. clusterAntiAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 不能匹配 matchLabels 的标签，则插件可以部署；<br/> 3. pluginAntiAffinity: 如果插件部署的集群已经存在同名的插件，则拒绝部署 | 否  |
| spec.deleteRiskDescription    | 插件的中文删除说明                                                                                                                                                                                                                                                                                                                           | 否  |
| deleteRiskDescriptionEn       | 插件的英文删除说明                                                                                                                                                                                                                                                                                                                           | 否  |
| spec.entrypointTemplate       | 插件部署后的配置入口                                                                                                                                                                                                                                                                                                                          | 否  |
| spec.resourcesBlockRemove     | 可阻止删除插件的资源。即只有这些资源被删除后才可以删除插件                                                                                                                                                                                                                                                                                                       | 否  |
| spec.labelCluster             | 是否在部署后给 cluster 打 label                                                                                                                                                                                                                                                                                                             | 否  |
| spec.config                   | 插件配置，数据来源于主 chart 的 scripts/plugin-config.yaml                                                                                                                                                                                                                                                                                      | 否  |
| spec.dependencies             | 插件依赖的模块，在部署或升级时必须等依赖的模块运行正常后才可操作当前插件                                                                                                                                                                                                                                                                                                | 否  |
| spec.deployDescriptors        | 插件动态表单 descriptors 配置                                                                                                                                                                                                                                                                                                               | 否  |
| spec.valuesTemplates          | valuesTemplates 定义了各个 chart 的配置模板，在创建或更新 AppRelease 时会将这部分数据渲染并填充到 chart 中                                                                                                                                                                                                                                                          | 否  |
| spec.targetClusterVersions    | 插件可部署的集群 ACP 版本                                                                                                                                                                                                                                                                                                                     | 否  |
| spec.uiContext                | 可选，插件前端 UI 配置                                                                                                                                                                                                                                                                                                                       | 否  |
