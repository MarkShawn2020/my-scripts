# 从0到1深入学习typescript、react、redux、electron

## 注意事项
### 遇到需要确认安装`webpack-dev-server`
直接按`Y`确认即可，或者提前在本地全局安装好：
```bash
npm install -g webpack-dev-server
```

### 遇到安装过程中出错的问题
可能是因为网络原因，可以重新安装一遍，或者继续安装未安装成功的那个包

### 关于`document`、`window`等非关键依赖，WebStorm `cannot find name`的问题
重新配置WebStorm里typescript所使用的的位置与版本：
```text
WebStorm > Preference > Language & FrameWorks > Typescript > Typescript
```
选择自己本地全局安装的Typescript（注意先更新到最新版，目前是4.2.4+），不要选用项目初始化的内置Typescript
