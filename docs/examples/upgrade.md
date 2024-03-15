# 升级插件

## 前置需求
你必须拥有一个 ACP Kubernetes 集群，同时插件的 chart 制品已部署到 chart 仓库中。
请先阅读 [deploy.md](deploy.md) 了解部署插件的步骤，接下来会在此环境基础上演示升级插件操作。

## 升级插件
1. 前面已经部署了 ModuleConfig v1 版本，接下来更新 chart 版本到 v2 并推送到 chart 仓库中。
2. 编辑 ProductBase，将 test-plugin 的版本由 v1 改为 v2：
    ```yaml
    apiVersion: product.alauda.io/v1alpha1
    kind: ProductBase
    spec:
      chartVersions:
      - name: ait/test-plugin
        version: v2
      ...
    ```
3. cluster-transformer 会创建出 v2 版本的 ModuleConfig 资源 [test-plugin-v2](yamls/moduleconfig-v2.yaml)，等 .status.readyForDeploy == true 时，说明该插件版本已经准备就绪。
4. 编辑 ModulePlugin，将 spec.version 改为 v2，命令如下：
    ```shell
    kubectl -n cpaas-system patch moduleplugin global-42f84b73493de7758b79e8ccea52b199 --type=merge --patch '{"spec": {"version": "v2"}}' 
    ```
5. 查看 AppRelease 以及 workloads 状态，确认插件版本更新到 v2。

## 接下来
- 阅读 [dynamic_form.md](dynamic_form.md) 了解动态表单的使用方法。