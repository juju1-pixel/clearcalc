# ClearCalc 啟動頁

## 畫面內容

- 延用現有計算器圖標與深藍、藍紫色調。
- 中央顯示 ClearCalc 與「讓數字慢一點」。
- 加號、時鐘、雙人與左右箭頭環繞中央 Logo，已移除四個功能名稱文字。
- 系統 LaunchScreen 顯示靜態起始排版；App 啟動後使用同一份 storyboard，四個圖標保持正向、環繞 Logo 一圈（1.2 秒），再淡出（0.25 秒）進入計算器。
- 每次 App 冷啟動播放一次，回到前景不重新播放；啟用「減少動態效果」時跳過旋轉。動畫無網路依賴，首頁可在下方準備，動畫期間不接受首頁點擊。

## 檔案

- `ClearCalc/LaunchScreen.storyboard`：完整啟動畫面，使用 Auto Layout；tag 100 是環繞容器，101–104 是圖標。
- `ClearCalc/Q5.swift`：使用 UIKit child view controller 載入相同 storyboard 並執行四段 90 度旋轉。
- `docs/launch-animation.mp4`：模擬器實錄的啟動動畫預覽。
- `ClearCalc/Assets.xcassets/LaunchBackground.imageset/LaunchBackground.png`：imagegen 產生的背景，853×1844。
- `ClearCalc/Assets.xcassets/LaunchMark.imageset/LaunchMark.png`：現有 AppIcon 的原樣複本；沒有改動原圖標。
- Debug / Release 均設定 `UILaunchStoryboardName = LaunchScreen`。
- 模擬器使用 Xcode 預設的本機簽名；不要傳入 `CODE_SIGNING_ALLOWED=NO`，否則部分模擬器版本會拒絕驗證啟動頁資源而顯示黑畫面。

## 圖像生成記錄

2026-09-11 驗證：Debug / Release 模擬器編譯通過；iPhone 17（iOS 26.0）已顯示完整系統啟動頁，正常啟動後進入計算器。

動畫更新驗證：四個功能名稱已移除；逐格檢查模擬器錄影，確認圖標順時針環繞一圈且保持正向、Logo 固定、動畫結束淡入計算器首頁。修正 UIKit 控制器嵌入問題後，Debug / Release 重新編譯通過，首頁正常顯示。

使用內建 image_gen 工具產生背景；品牌名稱、原圖標、功能文字及 SF Symbols 由 storyboard 疊加，讓完整啟動頁對應 App 的實際用途，文字清晰且不會隨背景裁切。

最終採用背景的提示詞：

```text
Use case: stylized-concept
Asset type: production background artwork for the native iPhone launch screen of ClearCalc, a calm, minimal calculator.
Primary request: Create a refined, quiet abstract vertical artwork that feels like softly illuminated glass and flowing light in deep navy space.
Composition: portrait 9:19.5, full bleed. Preserve a broad calm dark navy central zone from 30% to 70% of height so an existing small app icon and a white wordmark can be placed there by native UI. Delicate out-of-focus translucent glass arcs sweep along the upper right and lower left outer edges; large soft pools of indigo and muted lavender light, gentle depth, restrained luminosity. The central area must remain clean and dark, with no bright details under the future mark or text.
Palette: midnight navy #080D1C, deep blue #121D3B, periwinkle #6579FF, subtle violet. Dark edges, smooth nuanced gradients, premium frosted-glass atmosphere, exceptionally clean, contemporary and minimal.
Constraints: image only, no typography, no letters, no numbers, no icons, no calculator drawing, no logo, no watermark, no phone/device frame, no UI components, no stars or particles, no sharp busy geometry. Do not simulate a screenshot. This is the full-bleed artwork itself.
Output: high quality portrait raster image, ideally 1290 by 2796 pixels.
```
