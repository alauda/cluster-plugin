# 动态表单

动态表单，即前端预设一套内置的表单控件，并提供配置能力，让后端/用户能够通过配置直接生成表单。
使用动态表单的目的是，后端组件部署升级时的表单配置，可以由各组件后端维护，与前端业务代码解耦。

动态表单的使用方式参考 https://confluence.alauda.cn/pages/viewpage.action?pageId=103809501

## 前置需求
你必须拥有一个 ACP Kubernetes 集群，同时插件的 chart 制品已部署到 chart 仓库中。

## 使用动态表单
1. 假如在安装插件时，需要在前端增加一个文本框用以控制日志存储天数，可以在 chart 源码中增加 scripts/plugin-config.yaml，配置如下：
    ```yaml
    config:
      logRetentionDays: 7
    # 用动态表单的数据覆盖 chart 中 global.logRetentionDays 的值
    valuesTemplates:
      ait/test-plugin:
        global:
          # .MiConfig 是一个固定值，表示当前配置 config 字段
          logRetentionDays: .MiConfig.logRetentionDays
    deployDescriptors:
    # path 关联了 config.logRetentionDays 字段
    - path: logRetentionDays
      x-descriptors:
      - 'urn:alm:descriptor:com.tectonic.ui:number'
      - 'urn:alm:descriptor:com.tectonic.default:7'
      - 'urn:alm:descriptor:com.tectonic.ui:validation:maximum:30'
      - 'urn:alm:descriptor:com.tectonic.ui:validation:minimum:1'
      - 'urn:alm:descriptor:com.tectonic.ui:validation:required'
      - 'urn:alm:descriptor:label:en:applicationLog'
      - 'urn:alm:descriptor:label:zh:应用日志'
      - 'urn:alm:descriptor:description:en:1 day at least and 30 days at most'
      - 'urn:alm:descriptor:description:zh:最少 1 天，最多 30 天'
     ```
2. 将 chart 版本更新为 v3 并推送到 chart 仓库中。
3. 参考文档 [02_upgrade.md](upgrade.md) 操作插件升级流程。
4. 进入 ACP 控制台的插件列表页，展开 test-plugin 右侧按钮点击「更新配置参数」，即可看到表单。表单效果如图：
   ![dynamic_form.png](../../images/dynamic_form.png)