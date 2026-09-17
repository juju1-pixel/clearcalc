# ClearCalc

A deliberately small iPhone calculator built with SwiftUI. It supports addition, subtraction, multiplication, division, decimal values, sign changes, chained calculations, divide-by-zero recovery, and a limited, disclosed remote configuration layer.

## Help pages

- Help center: https://juju1-pixel.github.io/clearcalc/
- Privacy policy: https://juju1-pixel.github.io/clearcalc/privacy.html
- Support: https://juju1-pixel.github.io/clearcalc/support.html
- Support email: jju457489@gmail.com

Remote configuration can only update a short visible announcement and the calculator's accent color. It cannot control navigation, show websites, enable hidden functionality, or alter calculator behavior. Without a configuration URL, the app remains fully functional using its bundled fallback values.

## Open and run

1. Open `ClearCalc.xcodeproj` in Xcode 26 or later.
2. Under **Signing & Capabilities**, choose your Apple Developer team.
3. Change `com.yourname.ClearCalc` to a unique bundle identifier.
4. Run on an iPhone simulator or connected iPhone.

## Configure the HTTPS endpoint

Set `RemoteConfigURL` in the target's Build Settings to your own HTTPS JSON endpoint. Do not use a URL that redirects to a web page or accepts user data. The endpoint must return a JSON object no larger than 16 KB, such as:

```json
{
  "schemaVersion": 1,
  "announcement": "Welcome to ClearCalc",
  "accentHex": "#526BFF"
}
```

Invalid responses, non-HTTPS URLs, oversized files, unknown schema versions, and network failures are ignored. The app keeps its bundled fallback configuration.

## Before App Store submission

1. Replace the support email and publish `PrivacyPolicy.md` at a public HTTPS URL; add that URL to App Store Connect and the in-app About page.
2. Name the remote-configuration host and its request-log retention policy in the published privacy policy, then declare the relevant data practices accurately in App Store Connect.
3. Confirm the App Store name is available; "ClearCalc" is a working name, not a name-availability guarantee.
4. Create App Store screenshots on a 6.9-inch iPhone simulator, complete the age-rating questions, and declare that the app collects no data.
5. Archive the Release build and upload it through Xcode. TestFlight test it before submitting for review.
