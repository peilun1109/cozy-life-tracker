# 暖暖生活手帳 MVP

這是一個 Flutter 原型，定位是「可愛風格的個人生活紀錄與目標追蹤工具」。

## 目前版本

- Windows 桌面版可執行
- Web 版可執行，適合部署到 GitHub Pages
- 生活紀錄、目標、回顧、設定頁面可切換
- 基本 CRUD 可用
- 圖片可上傳
- Web 版資料保存在瀏覽器本地儲存

## Web 版目前的資料策略

為了讓 GitHub Pages 可直接使用，Web 版目前使用 `shared_preferences` 做本地持久化。

- 紀錄、目標、設定：保存在使用者瀏覽器本地
- 圖片：Web 版會轉成 base64 後保存在瀏覽器本地
- 不同使用者之間不會共享資料
- 清除瀏覽器網站資料後，內容會消失

這代表它非常適合做方向驗證、介面測試與使用者回饋蒐集，但還不是正式上線版後端架構。

## 本機開發

```bash
flutter pub get
flutter run -d chrome
```

如果要跑 Windows：

```bash
flutter run -d windows
```

## 部署到 GitHub Pages

專案已附上 GitHub Actions workflow：

- `.github/workflows/deploy_web.yml`

使用方式：

1. 把專案推到 GitHub
2. 預設分支使用 `main`
3. 到 GitHub repo 的 `Settings > Pages`
4. Source 選擇 `GitHub Actions`
5. Push 到 `main` 後會自動部署

Workflow 會自動用 repo 名稱作為 `base-href`，適合一般的 GitHub Pages 專案站點。

## 建議下一步

- 補真正的雲端後端，讓不同裝置可同步
- 把提醒升級成 Web Notification / Desktop Notification
- 增加資料匯出與匯入
- 補首頁與回顧頁的空狀態插畫與引導文案
