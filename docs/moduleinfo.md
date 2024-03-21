# ModuleInfo 配置说明

```yaml
apiVersion: cluster.alauda.io/v1alpha1
kind: ModuleInfo
metadata:
  annotations:
    cpaas.io/display-name: '{"en": "English Plugin Name", "zh": "插件中文名称"}'  # 显示名称
    cpaas.io/module-name: test-plugin  # 插件名称
  finalizers:
  - moduleinfo
  labels:
    cpaas.io/cluster-name: test-cluster # 插件所在集群
    cpaas.io/module-name: test-plugin # 插件名称
    cpaas.io/module-type: plugin # 固定字段
    cpaas.io/product: devops # 所属产品
  name: test-plugin-71d6ba072b3a9b02a0dfec35da192c4d
  # 将部署的集群对象设置为 ownerReferences
  ownerReferences:
  - apiVersion: platform.tkestack.io/v1
    kind: Cluster
    name: test-cluster
    uid: b6d19542-80cf-45b1-9df4-200f50807196
spec:
  # 创建插件时，前端动态表单渲染的配置
  config:
    self:
      storage:
        disabled: true
  version: v0.0.1 # 部署的插件版本
```

---------------
| 字段                       | 说明                                                                       | 必选 |
|--------------------------|--------------------------------------------------------------------------|----|
| metadata.name            | ModuleInfo CR 名称，为避免重名，插件后台最终会将名称格式改为 ${plugin-name}-${33 位长度的 hash 字符串} | 是  |
| spec.version             | 部署的集群版本                                                                  | 是  |
| metadata.ownerReferences | 插件所在集群。前端部署插件时，后台自动会添加集群引用                                               | 否  |
| spec.config              | 插件配置，配置方式参考文档 [scriptspluginconfig.md](scriptspluginconfig.md)           | 否  |
