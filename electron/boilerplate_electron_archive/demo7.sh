Description="基于ts、electron、react、redux、webpack、babel的桌面项目"
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
  "main": "src/electron/index.js",
  "scripts": {
    "start:main": "cross-env NODE_ENV=development electron -r ./scripts/babel_register ./src/main/index.ts",
    "start:renderer": "cross-env NODE_ENV=development webpack serve --config webpack.config.renderer.babel.js"
  }
}
EOF

echo "正在安装依赖包，如果遇到某些包未能安装成功（ERROR）的情况，可以尝试对它们重装，最后再通过package.json运行最终的程序"
# 主要用于生成绝对路径
yarn add path
# `react`用于构建组件，`react-dom`用于浏览器端与浏览器相关的api
yarn add react @types/react react-dom @types/react-dom
yarn add -D typescript
# webpack将react源程序打包，`webpack-cli`启动`webpack`要用
yarn add -D webpack webpack-cli
# 使用`serve`功能
yarn add webpack-dev-server
# `html-webpack-plugin`用于将打包的js植入html，`webpack-env`不安装无法使用`module.hot`热替换
yarn add -D html-webpack-plugin @types/webpack-env
# 模板热替换
yarn add -D  ts-loader source-map-loader
# redux
yarn add redux react-redux @types/react-redux
# redux-logger中间件可以让每个action都在控制台清晰的打印出来，非常适合开发调试
yarn add -D redux-logger @types/redux-logger
# redux-thunk支持异步更新
yarn add redux-thunk
# electron可以将web页面运行在桌面应用内
yarn add -D electron @types/electron
# babel相关可用于更方便的处理与ts、es有关的代码
yarn add -D @babel/core @babel/register @babel/preset-env @babel/preset-typescript
# 暂时还不知道具体作用
yarn add -D cross-env
fi

# @root
mkdir -p src && cd src
# @root/src

echo "=== 初始化redux模块 ==="
mkdir -p redux && cd redux
# @root/src/redux
echo "=== 新建score模块 ==="
mkdir -p score && cd score
# @root/src/redux/score

echo "1. 新建state"
cat > state.ts << EOF
// 声明State的接口，并初始化起始State（用于reducer的初始化，必需步骤）
export interface ScoreState {
  value: number
}

export const initScoreState: ScoreState = {
  value: 90
}
EOF

echo "2. 新建actionTypes"
cat > actionTypes.ts << EOF
// 1. 声明ActionType的类型
import { Action } from "redux";

export const ADD_SCORE = "ADD_SCORE";
export type ADD_SCORE = typeof ADD_SCORE;

export type DES_SCORE = typeof DES_SCORE;
export const DES_SCORE = "DES_SCORE";

// 2. 声明Action的接口
// 可以参考这个reference，自动构建action，但不是ts: https://cn.redux.js.org/docs/recipes/ReducingBoilerplate.html
export type ScoreActionType = ADD_SCORE | DES_SCORE;

export interface ScoreAction extends Action {
  type: ScoreActionType;
}
EOF

echo "3. 新建actions"
cat > actions.ts << EOF
// 3. 声明Action的函数
import { ADD_SCORE, DES_SCORE } from "./actionTypes";

export const addScore = () => ({
  type: ADD_SCORE,
});
export const desScore = () => ({
  type: DES_SCORE,
});

EOF

echo "4. 新建reducers"
cat > reducers.ts << EOF
// 定义reducer函数
import { initScoreState, ScoreState } from "./state";
import { ScoreAction } from "./actionTypes";

export const scoreReducer = (
  state = initScoreState,
  action: ScoreAction
): ScoreState => {
  switch (action.type) {
    case "ADD_SCORE":
      return { value: state.value + 1 };
    case "DES_SCORE":
      return { value: state.value - 1 };
    default:
      return state;
  }
};
EOF

echo "=== score模块新建完成 ==="

echo "=== 新建 score-async === "
cd .. && mkdir -p score-async && cd score-async
# @root/src/redux/score-async

echo "本项目为演示异步redux，故state部分与score模块共用，故跳过新建state部分"
echo "2. 新建actionTypes"
cat > actionTypes.ts << EOF
import { Action } from "redux";

export const ASYNC_ADD_SCORE = "ASYNC_ADD_SCORE";
export type ASYNC_ADD_SCORE = typeof ASYNC_ADD_SCORE;

export const ASYNC_DES_SCORE = "ASYNC_DES_SCORE";
export type ASYNC_DES_SCORE = typeof ASYNC_DES_SCORE;

export type ScoreAsyncActionType = ASYNC_ADD_SCORE | ASYNC_DES_SCORE;

export interface ScoreAsyncAction extends Action {
  type: ScoreAsyncActionType;
}
EOF

echo "3. 新建actions"
cat > actions.ts << EOF
import { Dispatch } from "redux";
import { addScore, desScore } from "../score/actions";

export const asyncAddScore = () => {
  return (dispatch: Dispatch) => {
    setTimeout(() => {
      dispatch(addScore());
    }, 1000);
  };
};
export const asyncDesScore = () => {
  return (dispatch: Dispatch) => {
    setTimeout(() => {
      dispatch(desScore());
    }, 1000);
  };
};
EOF

echo "4. 新建reducers"
cat > reducers.ts << EOF
import { initScoreState } from "../score/state";
import { ScoreAsyncAction } from "./actionTypes";
import { asyncAddScore, asyncDesScore } from "./actions";

export const scoreAsyncReducer = (
  state = initScoreState,
  action: ScoreAsyncAction
) => {
  switch (action.type) {
    case "ASYNC_ADD_SCORE":
      return asyncAddScore();
    case "ASYNC_DES_SCORE":
      return asyncDesScore();
    default:
      return state;
  }
};
EOF
echo  "=== 新建score-async模块完成"

echo "=== 组成两个redux模块到store里去 === "
cd ..
# @root/src/redux
cat > store.ts << EOF
import reduxThunk from "redux-thunk";
import reduxLogger from "redux-logger";
import { applyMiddleware, combineReducers, createStore } from "redux";
import { scoreReducer } from "./score/reducers";
import {scoreAsyncReducer} from "./score-async/reducers";

const rootReducer = combineReducers({
  score: scoreReducer,
  scoreAsync: scoreAsyncReducer,
});

export type AppState = ReturnType<typeof rootReducer>;

// 要注意，reduxThunk应该要放在reduxLogger之前，不然reduxLogger无法识别reduxThunk
const store = createStore(
  rootReducer,
  applyMiddleware(reduxThunk, reduxLogger)
);
export default store;

EOF
echo "=== redux初始化完成 === "

echo "=== 开始初始化react组件部分 === "
cd ..
mkdir -p renderer && cd renderer
# @root/src/renderer

echo "=== 新建 index.tsx 文件"
cat > index.tsx << EOF
import * as React from "react"
import * as ReactDOM from "react-dom"
import App from "./app"
import {Provider} from "react-redux";
import store from "../redux/store";

if (module.hot) {
  // 配置热更新
  module.hot.accept()
}

ReactDOM.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById("app")
)

EOF

echo "=== 新建app.tsx文件"
cat > app.tsx << EOF
import * as React from "react";
import { connect } from "react-redux";
import { AppState } from "../redux/store";
import { addScore, desScore } from "../redux/score/actions";
import { asyncAddScore, asyncDesScore } from "../redux/score-async/actions";
import { ScoreAction } from "../redux/score/actionTypes";
import { ScoreAsyncAction } from "../redux/score-async/actionTypes";

export interface AppProps {
  score: number;
  addScore: () => ScoreAction;
  desScore: () => ScoreAction;
  asyncAddScore: () => ScoreAsyncAction;
  asyncDesScore: () => ScoreAsyncAction;
}

export const App = (props: AppProps) => {
  return (
    <div>
      <h1>your score is: {props.score}</h1>
      <div>
        <button onClick={props.addScore}>ADD</button>
        <button onClick={props.desScore}>DES</button>
      </div>
      <div>
        <button onClick={props.asyncAddScore}>ADD_ASYNC</button>
        <button onClick={props.asyncDesScore}>DES_ASYNC</button>
      </div>
    </div>
  );
};

const mapState = (state: AppState) => ({
  score: state.score.value,
});

const mapDispatch = {
  addScore,
  desScore,
  asyncAddScore,
  asyncDesScore,
};

export default connect(mapState, mapDispatch)(App);

EOF

echo "=== 初始化electron模块 ==="
cd ..
# @root/src
mkdir -p main
cat > main/index.ts << EOF
import { BrowserWindow, app } from "electron";
import path from "path";

let win: BrowserWindow | null = null;

function createWindow() {
  win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });
  // win.webContents.openDevTools();
  const isDevelopment = process.env.NODE_ENV === "development";
  if(isDevelopment)
    win.loadURL("http://localhost:8080");
  else
    win.loadFile(path.join(__dirname, "../../dist/index.html"));
}

app.whenReady().then(() => {
  createWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });

  app.on("window-all-closed", app.quit);
});
EOF

echo "=== react组件初始化完成"

echo "=== 新建一个src/public/index.html模板文件"
# @root/src
mkdir -p public
echo "Main Reference: https://github.com/jantimon/html-webpack-plugin#configuration"
# 因为有了hmr，所以只需要提供一个#app即可，其他的脚本文件会自动打包引入
cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <title>Welcome to the world of Typescript, React, Redux, Electron </title>
  <meta charset="utf-8">
</head>
<body>
  <div id="app"></div>
</body>
</html>
EOF

# src

cd ..
# @root
echo "新建typescript配置文件"
echo "Main Reference: https://www.tslang.cn/docs/handbook/react-&-webpack.html"
# 其中：
# - `module`、`target`是为了兼容性而将代码编译成`es5`
# - `noImplicitAny`是为了规范书写
# - `lib`中`dom`不加的话无法识别`document.get...`语句
# - `jsx`必须设置成`react`才可以正常书写`jsx`组件
# - `allowSyntheticDefaultImports`不加的话就不可以使用`import React from "react"` 而只能使用`import * as React from "react"`
# - 但是，即使加上，ts不报错了，前端还是会报错，所以还是暂时先不加了
# - esModuleInterop 加上后可以解决import * as xx的问题，非常有用
cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "outDir": "./dist/",
    "sourceMap": true,
    "module": "commonjs",
    "target": "es5",
    "jsx": "react",
    "noImplicitAny": true,
    "esModuleInterop": true
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

echo "新建.babelrc文件"
cat > .babelrc << EOF
{
  "presets" : [
    "@babel/preset-env",
    "@babel/preset-typescript"
  ]
}
EOF

echo "新建用于electron预处理的babel注册文件"
mkdir -p scripts
cat > scripts/babel_register.js << EOF
const path = require("path");

console.log("babel registering...");

require("@babel/register")({
  extensions: [".es6", ".es", ".jsx", ".js", ".mjs", ".ts", ".tsx"],
  cwd: path.join(__dirname, ".."),
});
EOF

echo "新建webpack-base配置文件"
# output必须是绝对路径
cat > webpack.config.base.js << EOF
import path from "path";
const distPath = path.resolve("./dist");

export const basicConfig = {
  output: {
    path: distPath,
  },
  resolve: {
    extensions: [".ts", ".tsx", ".js", ".json"],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: "ts-loader",
      },
      {
        test: /\.js$/,
        use: "source-map-loader",
        enforce: "pre", // todo: 我也不知道这个到底有啥用
      },
    ],
  },
};

export default basicConfig;

EOF

echo "新建webpack-renderer配置文件"
echo "因为用到了ESM，所以需要用babel命名"
cat > webpack.config.renderer.babel.js << EOF
import { merge } from "webpack-merge";
import basicConfig from "./webpack.config.base.js";
import HtmlWebpackPlugin from "html-webpack-plugin";
import { spawn } from "child_process";

export const rendererConfig = merge(basicConfig, {
  target: "electron-renderer",
  entry: "./src/renderer/index.tsx",
  output: {
    filename: "renderer.js",
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/public/index.html",
      title: "已启用HMR热更新",
    }),
  ],
  devServer: {
    // 加上这条后，就可以在electron的network栏里点击相应文件并且不会有访问提示了，很有意思
    headers: { "Access-Control-Allow-Origin": "*" },
    // devServer内部的所有中间件执行之前的自定义执行函数，这里用于启动electron
	// In webpack 4, the api is `before`, and now(5) is `onBeforeSetupMiddleware`
	// reference: https://webpack.js.org/configuration/dev-server/#:~:text=devserver.onbeforesetupmiddleware
    onBeforeSetupMiddleware: (devServer) => {
      console.log("\n=== 正在启动Electron主进程 ===\n");
      spawn("npm", ["run", "start:main"], {
        shell: true,
        env: process.env,
        stdio: "inherit",
      })
        .on("close", (code) => process.exit(code))
        .on("error", (spawnError) => console.error(spawnError));
    },
  },
});

export default rendererConfig;
EOF


echo "启动Electron"
yarn start:renderer
