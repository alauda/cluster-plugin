# 部署插件

## 前置需求
你必须拥有一个 ACP Kubernetes 集群，同时插件的 chart 制品已部署到 chart 仓库中。

## 部署插件

1. 检查并确认 ProductBase 中包含了插件的 chartVersion 配置，需要与 ModulePlugin 中 spec.appReleases.chartVersions 的名称一致；
    ```yaml
    apiVersion: product.alauda.io/v1alpha1
    kind: ProductBase
    spec:
      chartVersions:
      - name: ait/test-plugin
        version: v1
      ...
    ```
2. 部署 ModulePlugin，命令如下：
   ```shell
   kubectl apply -f ./yamls/moduleplugin.yaml
   ```
   当前 ModulePlugin 中 chart version 是 refer-to-productbase，cluster-transformer 会从 ProductBase 获取真实版本。

   ```yaml
    appReleases:
    - chartVersions:
        - name: ait/test-plugin
          releaseName: test-plugin
          version: refer-to-productbase
   ```
   等待一段时间，cluster-transformer 会自动创建一个 ModuleConfig 资源 [test-plugin-v1](yamls/moduleconfig-v1.yaml)，当 .status.readyForDeploy == true 时，说明该插件版本已经准备就绪。
3. 部署 ModuleInfo，命令如下：
   ```shell
   kubectl apply -f ./yamls/moduleinfo.yaml
   ```
   ModuleInfo 的 cpaas.io/cluster-name 标签指定部署到 global 集群，spec.version 指定部署 v1 版本的插件，对应的会加载 ModuleConfig test-plugin-v1 实例。
   为了避免重名，后端会按照 ${目标集群名}-{32 长度的哈希值} 重建 ModuleInfo 资源，当前 ModuleInfo 部署后名字会变成类似 global-42f84b73493de7758b79e8ccea52b199。
4. cluster-transformer 创建了 ModuleInfo 资源后，也会根据 ModuleInfo 配置创建 AppRelease，查看 AppRelease 的命令如下：
   ```shell
   kubectl -n cpaas-system get appreleases test-plugin
   ```
5. 在查看 AppRelease 时也可以检查 workloads 的运行状态。

## 接下来
- 阅读 [upgrade.md](upgrade.md) 了解升级插件操作流程