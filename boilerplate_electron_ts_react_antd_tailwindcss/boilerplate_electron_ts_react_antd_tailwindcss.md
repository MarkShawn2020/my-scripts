1. [](#)
   1. [Step 1. Using Boilerplate of `electron-typescript-react`](#step-1-using-boilerplate-of-electron-typescript-react)
      1. [test](#test)
   2. [Step 2. Add Antd](#step-2-add-antd)
      1. [install `style-loader` and `css-loader` needed for `antd`](#install-style-loader-and-css-loader-needed-for-antd)
      2. [add `mjs, css(style-loader)` support since antd used mjs](#add-mjs-cssstyle-loader-support-since-antd-used-mjs)
      3. [add css import](#add-css-import)
   3. [Step 3. Add TailwindCSS](#step-3-add-tailwindcss)
      1. [add `postcss-loader` otherwise no effect (based on antd initialization)](#add-postcss-loader-otherwise-no-effect-based-on-antd-initialization)
   4. [All in One Script](#all-in-one-script)


## Boilerplate of `electron-typescript-react-antd-tailwindcss`

### Step 1. Using Boilerplate of `electron-typescript-react` 

```bash
PROJECT=${electron-typescript-react}
git clone https://github.com/diego3g/electron-typescript-react ${PROJECT}
cd ${PROJECT}
yarn
yarn install
```

#### test
```bash
yarn start
```

### Step 2. Add Antd
#### install `style-loader` and `css-loader` needed for `antd`
```bash
yarn add -D style-loader css-loader @types/antd
yarn add antd @ant-design/icons
```

#### add `mjs, css(style-loader)` support since antd used mjs

```zsh
echo '
    // mark >>> add support for antd
    // refer: https://stackoverflow.com/a/69519812/9422455
    {
        test: /\.m?js/,
        type: "javascript/auto",
        resolve: {
            fullySpecified: false,
        },
    },
    {
        test: /\.css$/,
        use: [
            {loader: "style-loader"},
            {loader: "css-loader"},
            // {loader: "postcss-loader"},
        ],
    },
    // mark <<<
'  | sed -i '' '/module.exports/r /dev/stdin' webpack/rules.webpack.js
```

!!!
    the `sed -i '' ` is specialized for Mac, more details on it please refer to [inplace-sed-from-stdin](../../Linux/linux-howto.md#inplace-sed-from-stdin)

!!! WARNING
    the `css` used by antd will change some default appearance like `bg-color`.

#### add css import 
```bash
gsed -i '1i import "antd/dist/antd.css"' ./src/index.tsx
```

### Step 3. Add TailwindCSS
```bash
yarn add -D tailwindcss@2.0.1-compat postcss  autoprefixer postcss-loader
npx tailwindcss init -p

# add post
sed -i '' 's/\/\/ {loader: "postcss-loader"}/{loader: "postcss-loader"}/' webpack/rules.webpack.js

echo '  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],' | sed -i '' '/module.export/r /dev/stdin' tailwind.config.js

echo '@tailwind base;`
@tailwind components;
@tailwind utilities;
' >> src/index.css

gsed -i '1i import "./index.css"' src/index.tsx
```

#### add `postcss-loader` otherwise no effect (based on antd initialization)
```bash
 sed -i '' 's/\/\/ {loader: "postcss-loader"}/{loader: "postcss-loader"}/' webpack/rules.webpack.js
```

### All in One Script
refer to: [boilerplate_electron_ts_react_antd_tailwindcss](..lectron_ts_react_antd_tailwindcss.sh)
