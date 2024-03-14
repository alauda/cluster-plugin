
# ModuleConfig 配置说明
ModuleConfig 是由 ModulePlugin 自动创建的，有很多字段与 ModuleConfig 相同。该资源不需要人工配置。
```yaml
apiVersion: cluster.alauda.io/v1alpha1
kind: ModuleConfig
metadata:
  annotations:
    cpaas.io/built-in-plugin: "true"  # 表示是否是内置 plugin，cluster-transformer 只为内置 plugin 创建 ModuleConfig 资源
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}'  # 插件中英文名称
    cpaas.io/module-name: test-plugin  # 插件名称
    helm.sh/chart-version: v3.16.0-beta.6.g88ffb8c7
    helm.sh/original-name: test-plugin
  finalizers:
    - moduleconfig
  labels:
    cpaas.io/module-catalog: devops
    cpaas.io/module-name: test-plugin
    cpaas.io/module-type: plugin  # 取值必须为 plugin，表示当前模块是插件
    cpaas.io/module-version: v1  # 插件的版本
    cpaas.io/product: ACP # 插件所属产品
    helm.sh/chart-name: base-plugins
    helm.sh/release-name: base-plugins
    helm.sh/release-namespace: cpaas-system
  name: test-plugin-v1
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
  config: # 插件自定义 config 配置。常用来配合 spec.deployDescriptors 渲染动态表单
    self:
      storage:
        disabled: true
  deleteRiskDescription: 中文 # 删除插件风险提示中文文案
  deleteRiskDescriptionEn: English # 删除插件风险提示英文文案
  deleteable: true # 插件是否可以删除
  dependencies: # 插件依赖的模块，在部署或升级时必须等依赖的模块运行正常后才可操作当前插件
    - moduleName: base
      versionsMatch:
        - '*'
  # 插件动态表单配置。详细的配置说明可以参考 https://confluence.alauda.cn/pages/viewpage.action?pageId=103809501
  deployDescriptors:
    # 这里将 spec.config.self.storage.disabled 定义为一个开关，默认值 false。
    # 该开关值也可以被 spec.valuesTemplates 引用，并最终渲染到插件的 chart 中。
    - description: ""
      path: self.storage.disabled
      x-descriptors:
        - urn:alm:descriptor:com.tectonic.ui:booleanSwitch
        - urn:alm:descriptor:com.tectonic.default:false
  # valuesTemplates 定义了各个 chart 的配置模板，在创建或更新 AppRelease 时会将这部分数据渲染并填充到 chart 中
  valuesTemplates:
    ait/test-plugin:
      global:
        # .MiConfig 是一个固定值，表示当前配置的 spec.config
        storageEnabled: .MiConfig.self.storage.disabled
  mainChart: ait/test-plugin  # 主 chart，如果插件只有一个 chart，ModuleConfig 版本号即主 chart 版本号
  name: test-plugin
  supportedUpgradeVersions: '>= v1.0.0' # 插件的目标版本需要满足的版本范围
  targetClusterVersions: # 插件可部署的集群 ACP 版本
    - v3.16.0-alpha.595
  uiContext:
    sizeSettings:
      quotaTip: {}
  upgradeRiskDescription: 中文 # 插件升级风险提示中文文案
  upgradeRiskDescriptionEn: English # 插件升级风险提示英文文文案
  upgradeRiskLevel: low # 插件升级风险等级，可取值：low, middle, high
  version: v1 # 当前 ModuleConfig 版本
status:
  readyForDeploy: true # 当前 ModuleConfig 是否满足部署条件
  targetClusterVersions: # 插件可以部署的集群 ACP 版本
    - v3.16.0-alpha.595
```