# ModuleInfo 配置说明

```yaml
apiVersion: cluster.alauda.io/v1alpha1
kind: ModuleInfo
metadata:
  annotations:
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}'  # 插件中英文名称
    cpaas.io/module-name: test-plugin  # 插件名称
  finalizers:
  - moduleinfo
  labels:
    cpaas.io/cluster-name: test-cluster # 插件部署的集群
    cpaas.io/module-name: test-plugin # 部署的插件名称
    cpaas.io/module-type: plugin # 取值必须为 plugin，表示当前模块是插件
    cpaas.io/product: ACP
    create-by: cluster-transformer
    manage-delete-by: cluster-transformer
    manage-update-by: cluster-transformer
  name: test-plugin-71d6ba072b3a9b02a0dfec35da192c4d
  # 将部署的集群对象设置为 ownerReferences
  ownerReferences:
  - apiVersion: platform.tkestack.io/v1
    kind: Cluster
    name: test-cluster
    uid: b6d19542-80cf-45b1-9df4-200f50807196
spec:
  # 插件自定义 config 配置，与 ModuleConfig 中 spec.config 含义相同。
  # 他们的区别在于 ModuleConfig 中的 spec.config 是 chart 中模版静态值，
  # 而 ModuleInfo 中的 spec.config 是实时动态值，
  # 渲染 chart 时会以 ModuleInfo 的配置为准
  config:
    self:
      storage:
        disabled: true
  version: v1 # 部署的插件版本
status:
  # 当前 AppRelease 版本信息以及运行状态
  appReleases:
  - chartVersions:
    - name: ait/test-plugin
      releaseName: test-plugin
      version: v1
    failed: false
    lastProbeTime: "2024-03-11T05:22:24Z"
    message: resources state ready
    name: test-plugin
    ready: true
    reason: Ready
    synced: true
  # 可以选择的插件版本，该示例表示插件有 v1 和 v2 两个版本，当前部署 v1 版本
  availableVersions:
  - dependencies:
    - moduleName: base
      versionsMatch:
      - '*'
    description: 对用户已部署的应用无影响
    descriptionEn: No effect on user-deployed applications.
    riskLevel: low
    version: v1
  - dependencies:
      - moduleName: base
        versionsMatch:
          - '*'
    description: 对用户已部署的应用无影响
    descriptionEn: No effect on user-deployed applications.
    riskLevel: low
    version: v2
  conditions:
  - lastProbeTime: "2024-03-11T05:22:24Z"
    lastTransitionTime: "2024-03-11T05:22:24Z"
    message: ready
    reason: Ready
    status: Success
    type: CheckStatus
  moduleconfigSpecHash: fe7b62b51891029dff6779684e17d553f7dcd82691179e4da7db9bab0c2a5b64 # 引用的 ModuleConfig spec 内容的哈希值
  phase: Running
  removeIsPrevented: false # 删除是否被阻塞，如果集群中存在 ModulePlugin spec.resourcesBlockRemove 资源是会阻塞删除插件
  specHash: b3f2142a4ef9de52b89d20f01c4adabf6f13335f34fbf8b79b1806d96f4d392b # 当前 ModuleInfo spec 内容的哈希值
  transitTimeout: 1200000000000
  transitVersion: v1 # 部署时的插件版本
  version: v1 # 当前部署的插件版本
```