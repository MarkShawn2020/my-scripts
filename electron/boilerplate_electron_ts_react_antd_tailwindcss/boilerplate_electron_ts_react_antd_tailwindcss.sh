read -p "Input Project Name: " PROJECT

# clone 
git clone https://github.com/diego3g/electron-typescript-react ${PROJECT}
cd ${PROJECT}
yarn
yarn install

# add antd
yarn add -D style-loader css-loader @types/antd
yarn add antd @ant-design/icons
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
gsed -i '1i import "antd/dist/antd.css"' ./src/index.tsx

# add tailwindcss
yarn add -D tailwindcss@2.0.1-compat postcss  autoprefixer postcss-loader
npx tailwindcss init -p
sed -i '' 's/\/\/ {loader: "postcss-loader"}/{loader: "postcss-loader"}/' webpack/rules.webpack.js
echo '  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],' | sed -i '' '/module.export/r /dev/stdin' tailwind.config.js

echo '@tailwind base;
@tailwind components;
@tailwind utilities;
' >> src/index.css
gsed -i '1i import "./index.css"' src/index.tsx
sed -i '' 's/\/\/ {loader: "postcss-loader"}/{loader: "postcss-loader"}/' webpack/rules.webpack.js