# Plugin Packager

## 插件工作原理
![how_plugin_works.png](images/how_plugin_works.png)

插件的安装和管理是由 global 集群的 cluster-transformer 组件实现的。cluster-transformer 提供了很多 controller，与插件相关的 controller 主要有三个：

- moduleplugin-controller：协调 ModulePlugin 资源，该资源定义了插件所需的 AppRelease、Logo、显示名称、展示或升级时的中英文文案等信息，资源状态会更新插件部署的集群以及插件版本信息、关联的 ModuleConfig 信息。该 controller 也会为每个插件版本创建一个 ModuleConfig 资源，如果插件提供了动态表单，也会把表单配置信息填充到对应版本的 ModuleConfig 资源中。
- moduleconfig-controller：协调 ModuleConfig 资源，该资源定义了插件某个版本的配置信息，具体包括：亲和反亲和配置、AppRelease 列表、动态表单配置、依赖的 Module、主 Chart 等；
- moduleinfo-controller：协调 ModuleInfo 资源，该资源定义了插件部署的目标集群、插件版本、插件 Entrypoint 等。controller 会根据插件版本选择对应的 ModuleConfig 在目标集群安装 AppRelease。

结合上图，插件的工作流程如下：
1. 先把 ModulePlugin 部署到集群，moduleplugin-controller 会结合 ModulePlugin、ProductBase、从 sentry 请求插件配置文件（文件中包含了动态表单配置）plugin-config.yaml 生成或更新 ModuleConfig 资源；
   1. 如果 ModulePlugin 的 spec.appReleases[].version 值是 refer-to-productbase，表示 chart 的版本参考 ProductBase，否则以 ModulePlugin 的值为准；
   2. ModulePlugin 会向 sentry 加载指定版本的 chart 中 scripts/plugin-config.yaml 内容，该配置里包含了插件的详细配置，比如 supportedUpgradeVersions 定义了可支持升级的版本，deployDescriptors 定义了动态表单配置。
2. moduleplugin-controller 根据 AppRelease 中所有 chart 的版本计算出新的版本号作为 ModuleConfig 的版本，并创建 ModuleConfig。这也意味着只要 AppRelease 的 chart 中任何一个版本发生了变化，moduleplugin-controller 就会创建出一个新的 ModuleConfig 资源。
3. 用户创建 ModuleInfo 资源，该资源指定了插件版本、插件需要部署的集群以及插件的依赖。moduleinfo-controller 等待插件的依赖运行正常之后才会往目标集群部署插件的 AppRelease 资源。
4. 目标集群的 sentry 服务监听到 AppRelease 的请求，会下载对应的 chart 并协调出 workloads，直到所有的 workloads 运行正常，更新 AppRelease 的状态。

## 配置说明
为方便自定义插件，这里整理了 ModulePlugin、ModuleConfig 和 ModuleInfo 资源的常见配置：
1. ModulePlugin: [moduleplugin.md](docs/moduleplugin.md)
2. ModuleConfig: [moduleconfig.md](docs/moduleconfig.md)
3. ModuleInfo: [moduleinfo.md](docs/moduleinfo.md)

## 使用示例
这里列举一些常见的使用示例：
1. 部署插件: [deploy.md](docs/examples/deploy.md)
2. 更新插件版本: [upgrade.md](docs/examples/upgrade.md)
3. 动态表单: [dynamic_form.md](docs/examples/dynamic_form.md)