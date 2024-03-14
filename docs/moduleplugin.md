# ModulePlugin 配置说明

```yaml
kind: ModulePlugin
metadata:
  annotations:
    cpaas.io/built-in-plugin: "true"  # 表示是否是内置 plugin，cluster-transformer 只为内置 plugin 创建 ModuleConfig 资源
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}'  # 插件中英文名称
    cpaas.io/module-name: test-plugin  # 插件名称
  labels:
    cpaas.io/module-catalog: devops
    cpaas.io/module-name: test-plugin
    cpaas.io/module-type: plugin # 取值必须为 plugin，表示当前模块是插件
    cpaas.io/product: ACP
    helm.sh/chart-name: base-plugins
    helm.sh/release-name: base-plugins
    helm.sh/release-namespace: cpaas-system
  name: test-plugin
spec:
  # 插件亲和配置。亲和类型有 clusterAffinity、clusterAntiAffinity 和 pluginAntiAffinity 三类。
  # - clusterAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 能够匹配 matchLabels 的标签，则插件可以部署；
  # - clusterAntiAffinity: 如果插件部署的集群资源 clusters.platform.tkestack.io 不能匹配 matchLabels 的标签，则插件可以部署；
  # - pluginAntiAffinity: 如果插件部署的集群已经存在同名的插件，则拒绝部署
  affinity:
    pluginAntiAffinity:
    - test-plugin
  appReleases:
  - chartVersions:
    - name: ait/test-plugin
      releaseName: test-plugin
      version: refer-to-productbase
    name: test-plugin
  deleteRiskDescription: 中文 # 删除插件风险提示中文文案
  deleteRiskDescriptionEn: English # 删除插件风险提示英文文案
  deleteable: true # 插件是否可以删除
  description:
    en: English # 插件功能描述，英文
    zh: 中文 # 插件功能描述，中文
  labelCluster: "true"
  logo: data:image/svg+xml;base64,xxx # logo
  mainChart: ait/test-plugin # 主 chart，如果插件只有一个 chart，ModuleConfig 版本号即主 chart 版本号
  name: test-plugin
  upgradeRiskDescription: 中文 # 插件升级风险提示中文文案
  upgradeRiskDescriptionEn: English # 插件升级风险提示英文文文案
  upgradeRiskLevel: low # 插件升级风险等级，可取值：low, middle, high
  resourcesBlockRemove: # 可阻止删除插件的资源。即只有这些资源被删除后才可以删除插件
  - apiVersion: test.alauda.io/v1beta1
    kind: BlockService
  
status:
  installed: # 插件部署信息。该示例表示插件部署在两个集群，global 集群部署的 v1 版本，test-cluster 集群部署的 v2 版本
  - cluster: global
    name: global-e671599464a5b1717732c5ba36079795 # 插件的 ModuleInfo 资源
    phase: Running
    version: v1
  - cluster: test-cluster
    name: test-cluster-71d6ba072b3a9b02a0dfec35da192c4d # 插件的 ModuleInfo 资源
    phase: Running
    version: v2
  latestVersion: v2 # 插件可部署的最新版本
  moduleConfigs: # 插件版本信息，即插件的 ModuleConfig 资源信息。当前示例表示，该插件目前有两个 ModuleConfig，版本分别是 v1 和 v2，可部署的集群 ACP 版本：v3.16.0-alpha.595
  - affinity:
      pluginAntiAffinity:
      - test-plugin
    name: test-plugin-v1
    readyForDeploy: true
    targetClusterVersions:
    - v3.16.0-alpha.595
    version: v1
  - affinity:
      pluginAntiAffinity:
        - test-plugin
    name: test-plugin-v2
    readyForDeploy: true
    targetClusterVersions:
    - v3.16.0-alpha.595
    version: v2
  # targetClusterVersions 表示插件可部署的集群 ACP 版本
  targetClusterVersions:
    v3.16.0-alpha.595:
      affinity:
        pluginAntiAffinity:
        - test-plugin
      description:
        en: English
        zh: 中文
      logo: data:image/svg+xml;base64,xxx
      moduleConfigSpecHash: fe7b62b51891029dff6779684e17d553f7dcd82691179e4da7db9bab0c2a5b64
      readyForDeploy: true
      version: v3.16.0-beta.23.g1e74fa6e
```