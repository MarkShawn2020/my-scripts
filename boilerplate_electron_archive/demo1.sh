Description="ts-react-webpack"
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
echo "re-install: "${ReInstall}

# 如果不存在`package.json`文件，或者重装参数为真，则重装依赖
if [[ ! -f "package.json" || ${ReInstall} = true ]]
then
echo "初始化package.json"
cat > package.json << EOF
{
  "name": "${ProjectName}",
  "description": "${Description}",
  "version": "0.0.1",
  "author": "mark",
  "mail": "shawninjuly@gmail.com",
  "license": "MIT",
  "scripts": {
    "dev": "webpack --config ./webpack.config.js --mode=development && open ./index.html"
  }
}
EOF

echo "安装依赖包"
# 主要用于生成绝对路径
yarn add path
# `react`用于构建组件，`react-dom`用于浏览器端与浏览器相关的api
yarn add react @types/react react-dom @types/react-dom
yarn add -D typescript
# webpack将react源程序打包
yarn add -D webpack source-map-loader ts-loader
fi

echo "新建html主体文件"
cat > index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <title> Hello React </title>
  <meta charset="utf-8">
</head>
<body>
  <div id="app"></div>

  <!-- Dependencies -->
  <script src="./node_modules/react/umd/react.development.js"></script>
  <script src="./node_modules/react-dom/umd/react-dom.development.js"></script>


  <!-- Main -->
  <script src="./dist/bundle.js"></script>
</body>
</html>
EOF

mkdir -p src && cd src
echo "新建react前端程序的入口文件"
mkdir -p renderer
cat > renderer/index.tsx << EOF
import * as React from "react"
import * as ReactDOM from "react-dom"
import App from "./app"

ReactDOM.render(
  <App/>,
  document.getElementById("app")
)
EOF

echo "新建react前端程序的主文件"
cat > renderer/app.tsx << EOF
import * as React from "react"

export const App = () => {
  return (
    <h1>hello world</h1>
  )
}

export default App
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

module.exports = {
  entry: "./src/renderer/index.tsx",
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
  },
    // When importing a module whose path matches one of the following, just
    // assume a corresponding global variable exists and use that instead.
    // This is important because it allows us to avoid bundling all of our
    // dependencies, which allows browsers to cache those libraries between builds.
    externals: {
        "react": "React",
        "react-dom": "ReactDOM"
    }
}
EOF

echo "执行webpack"
# 如果不加`mode`，会有警告（默认是`production`）
webpack --config ./webpack.config.js --mode=development

echo "顺利初始化，尝试打开浏览器"
open ./index.html
