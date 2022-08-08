Description="基于ts、react、webpack的前端项目，搭配react-redux、redux-logger"
ProjectName=${0%.*}
ProjectName=${ProjectName##*/}
echo "Directory Name: "${ProjectName}
mkdir -p ${ProjectName} && cd ${ProjectName}

# 通过参数判断是否要重装依赖包
ReInstall=false
while getopts ":r" optname;
do
  case $optname in
  "r")
    ReInstall=true
    ;;
  "?")
    echo "error: no this argument!"
    exit 1
    ;;
  esac
done

# 如果不存在`package.json`文件，或者重装参数为真，则重装依赖
if [[ ! -f "package.json" || ${ReInstall} = true ]]
then
echo "初始化package.json"
cat > package.json << EOF
{
  "name": "${ProjectName}",
  "version": "0.0.1",
  "description": "${Description}",
  "author": "mark",
  "mail": "shawninjuly@gmail.com",
  "license": "MIT",
  "main": "src/index.tsx",
  "scripts": {
    "start": "webpack serve --open"
  }
}
EOF

echo "安装依赖包，如果遇到某些包未能安装成功（ERROR）的情况，可以尝试对它们重装，最后再通过package.json运行最终的程序"
echo "本版结合了react-redux，可供基础组件设计的生产学习使用"
# 主要用于生成绝对路径
yarn add path
# `react`用于构建组件，`react-dom`用于浏览器端与浏览器相关的api
yarn add react @types/react react-dom @types/react-dom
yarn add -D typescript
# webpack将react源程序打包，`webpack-cli`启动`webpack`要用
yarn add -D webpack webpack-cli
# 使用`serve`功能
yarn add -D webpack-dev-server
# `html-webpack-plugin`用于将打包的js植入html，`webpack-env`不安装无法使用`module.hot`热替换
yarn add -D html-webpack-plugin @types/webpack-env
# 模板热替换
yarn add -D  ts-loader source-map-loader
# redux
yarn add redux react-redux @types/react-redux
# redux-logger中间件可以让每个action都在控制台清晰的打印出来，非常适合开发调试
yarn add -D redux-logger @types/redux-logger
fi

echo "新建html主体文件"
echo "Main Reference: https://github.com/jantimon/html-webpack-plugin#configuration"
# 因为有了hmr，所以只需要提供一个#app即可，其他的脚本文件会自动打包引入
cat > index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <title> Hello React </title>
  <meta charset="utf-8">
</head>
<body>
  <div id="app"></div>
</body>
</html>
EOF

mkdir -p src && cd src
echo "新建store文件"
cat > store.ts << EOF
import {applyMiddleware, createStore} from "redux";
import reduxLogger from "redux-logger";

// 1. 声明State的接口，并初始化起始State（用于reducer的初始化，必需步骤）
export interface ScoreState {
  score: number
}

const initScoreState: ScoreState = {
  score: 90
}

// 2. 声明ActionType的类型
export const ADD_SCORE = "ADD_SCORE"
export type ADD_SCORE = typeof ADD_SCORE

export type DES_SCORE = typeof DES_SCORE
export const DES_SCORE = "DES_SCORE"

export type ScoreActionType = ADD_SCORE | DES_SCORE

// 3. 声明Action的接口
// 可以参考这个reference，自动构建action，但不是ts: https://cn.redux.js.org/docs/recipes/ReducingBoilerplate.html
export interface ScoreAction {
  type: ScoreActionType
}

export const addScore: ScoreAction = {
  type: ADD_SCORE
}
export const desScore: ScoreAction = {
  type: DES_SCORE
}


// 3. 定义reducer函数
export const scoreReducer = (state = initScoreState, action: ScoreAction): ScoreState => {
  switch (action.type) {
    case "ADD_SCORE":
      return {score: state.score + 1}
    case "DES_SCORE":
      return {score: state.score - 1}
    default:
      return state
  }
}

// 4. 初始化store，并配置一些中间件（可选）
const store = createStore(scoreReducer,  applyMiddleware(reduxLogger))
export default store
EOF

echo "新建react前端程序的入口文件"
# 如果document提示找不到，就要关闭一下WebStorm的typescript语言服务
cat > index.tsx << EOF
import * as React from "react"
import * as ReactDOM from "react-dom"
import App from "./app"
import {Provider} from "react-redux";
import store from "./store";

if (module.hot) {
  // 配置热更新
  module.hot.accept()
}

if(outerHeight - innerHeight < 200 && outerWidth - innerWidth < 20) {
  alert("请打开控制台，以更好地查看redux-logger的输出")
}

ReactDOM.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById("app")
)
EOF

echo "新建react前端程序的主文件"
cat > app.tsx << EOF
import * as React from "react"
import {addScore, desScore, ScoreState} from "./store";
import {connect} from "react-redux";
import {Dispatch} from "redux";

export interface AppProps {
  score: number
  addScore: () => ScoreAction
  desScore: () => ScoreAction
}

export const App = (props: AppProps) => {
  return (
    <div>
      <h1>your score is: {props.score}</h1>
      <button onClick={props.addScore}>ADD</button>
      <button onClick={props.desScore}>DES</button>
    </div>
  )
}

const mapState = (state: ScoreState) => ({
  score: state.score
})

const mapDispatch = (dispatch: Dispatch) => ({
  addScore: () => dispatch(addScore),
  desScore: () => dispatch(desScore)
})

export default connect(mapState, mapDispatch)(App)
EOF


cd ..
echo "Main Reference: https://www.tslang.cn/docs/handbook/react-&-webpack.html"
echo "新建typescript配置文件"
# 其中：
# - `module`、`target`是为了兼容性而将代码编译成`es5`
# - `noImplicitAny`是为了规范书写
# - `lib`中`dom`不加的话无法识别`document.get...`语句
# - `jsx`必须设置成`react`才可以正常书写`jsx`组件
# - `allowSyntheticDefaultImports`不加的话就不可以使用`import React from "react"` 而只能使用`import * as React from "react"`
# - 但是，即使加上，ts不报错了，前端还是会报错，所以还是暂时先不加了
cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "outDir": "./dist/",
    "sourceMap": true,
    "module": "commonjs",
    "target": "es5",
    "jsx": "react",
    "noImplicitAny": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF

echo "新建webpack配置文件"
# output必须是绝对路径
cat > webpack.config.js << EOF
const path = require("path")
const HTMLWebpackPlugin = require("html-webpack-plugin")

module.exports = {
  mode: "development",
  devtool: "inline-source-map",
  devServer: {
    contentBase: "./dist",  // 将 dist 目录下的文件 serve 到 localhost:8080 下
    hot: true
  },
  plugins: [
    new HTMLWebpackPlugin({
      template: "./index.html"
    })
  ],
  entry: "./src/index.tsx",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "bundle.js"
  },
  resolve: {
    extensions: [".ts", ".tsx", ".js", ".json"],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: "ts-loader"
      },
      {
        test: /\.js$/,
        use: "source-map-loader",
        enforce: "pre"  // todo: 我也不知道这个到底有啥用
      }
    ]
  }
}
EOF

echo "执行webpack"
# 如果不加`mode`，会有警告（默认是`production`）
yarn start
