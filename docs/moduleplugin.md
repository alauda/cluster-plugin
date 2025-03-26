# ModulePlugin 配置说明

## 配置说明
```yaml
kind: ModulePlugin
metadata:
  annotations:
    cpaas.io/built-in-plugin: "false" # 标识是否产品集成的插件
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}' # 显示名称
    cpaas.io/module-name: test-plugin # 插件名称
  labels:
    cpaas.io/module-catalog: devops # 可选，插件分类
    cpaas.io/module-name: test-plugin # 插件名称
    cpaas.io/module-type: plugin # 固定字段
    cpaas.io/product: devops # 所属产品
  name: test-plugin # 插件名称
spec:
  # 可选， 插件的部署限制, 仅当有限制时填写
  affinity:
    pluginAntiAffinity:
    - test-plugin
  appReleases:
  - chartVersions:
    - name: ait/chart-example
      releaseName: chart-example
      version: v0.0.1
    name: test-plugin
  deleteRiskDescription: 中文 # 可选，删除插件风险提示中文文案
  deleteRiskDescriptionEn: English # 可选，删除插件风险提示英文文案
  deleteable: true # 插件是否可以删除
  description:
    en: English # 插件功能描述，英文
    zh: 中文 # 插件功能描述，中文
  labelCluster: "true"
  logo: data:image/svg+xml;base64,xxx # logo 为 base64 后的 svg 数据，在线压缩svg工具: https://vecta.io/nano
  mainChart: ait/test-plugin # 主 chart, 存放有插件配置项 scripts/plugin-config.yaml
  name: test-plugin
  upgradeRiskDescription: 中文 # 可选，插件升级风险提示中文文案
  upgradeRiskDescriptionEn: English # 可选，插件升级风险提示英文文案
  upgradeRiskLevel: low # 可选，插件升级风险等级，可取值：low, middle, high
  resourcesBlockRemove: # 可选，可阻止删除插件的资源。即只有这些资源被删除后才可以删除插件
  - apiVersion: test.alauda.io/v1beta1
    kind: BlockService
```

---------------
| 字段                          | 说明                                                                                                                                                                                                                                                                                                                                  | 必选 |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----|
| spec.appReleases            | 将 chart 组织成 apprelease 形式由 sentry 安装,　apprelease 会被并行安装                                                                                                                                                                                                                                                                             | 是  |
| spec.deleteable             | 插件是否可删除                                                                                                                                                                                                                                                                                                                             | 是  |
| spec.description            | 插件的中英文描述                                                                                                                                                                                                                                                                                                                            | 是  |
| spec.logo                   | logo 为 base64 后的 svg 数据，在线压缩svg工具: https://vecta.io/nano                                                                                                                                                                                                                                                                            | 是  |
| spec.mainChart              | 主 chart, 存放有插件配置项 scripts/plugin-config.yaml                                                                                                                                                                                                                                                                                        | 是  |
| spec.name                   | 插件名称                                                                                                                                                                                                                                                                                                                                | 是  |
| spec.upgradeRiskDescription | 插件的升级说明                                                                                                                                                                                                                                                                                                                             | 否  |
| spec.upgradeRiskLevel       | 插件的升级风险等级，可取值：low, middle, high                                                                                                                                                                                                                                                                                                     | 否  |
| spec.affinity               | 插件亲和配置。亲和类型有 clusterAffinity、clusterAntiAffinity 和 pluginAntiAffinity 三类。<br/>1. clusterAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 能够匹配 matchLabels 的标签，则插件可以部署； <br/>2. clusterAntiAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 不能匹配 matchLabels 的标签，则插件可以部署；<br/> 3. pluginAntiAffinity: 如果插件部署的集群已经存在同名的插件，则拒绝部署 | 否  |
| spec.deleteRiskDescription  | 插件的删除说明                                                                                                                                                                                                                                                                                                                             | 否  |
| spec.entrypointTemplate     | 插件部署后的配置入口                                                                                                                                                                                                                                                                                                                          | 否  |
| spec.resourcesBlockRemove                       | 可阻止删除插件的资源。即只有这些资源被删除后才可以删除插件                                                                                                                                                                                                                                                                                                       | 否  |
| spec.labelCluster           | 是否在部署后给 cluster 打 label                                                                                                                                                                                                                                                                                                             | 否  |
