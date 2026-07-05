# Build and install

## Build on GitHub from Windows

1. Make an empty GitHub repository.
2. Extract `legacyios_milestone_0.1.zip`.
3. Upload the contents of the `legacyios` folder to the repository root.
4. Open the repository's Actions tab.
5. Open `build unsigned ipa` and choose `Run workflow`.
6. When the run finishes, download the `LegacyiOS-unsigned` artifact.
7. Extract the downloaded artifact ZIP. The file inside is `LegacyiOS-unsigned.ipa`.

## ESign

1. Import `LegacyiOS-unsigned.ipa` into ESign.
2. Open the unsigned app list and select LegacyiOS.
3. Choose Signature.
4. Select your own certificate and provisioning profile.
5. Sign the app, then choose Install.
6. Approve or trust the developer profile in iOS Settings if iOS requests it.

## Sideloadly

1. Connect the iPhone to the PC and trust the computer.
2. Open Sideloadly and select the connected iPhone.
3. Drag `LegacyiOS-unsigned.ipa` into Sideloadly.
4. Enter the Apple ID used for signing and start the install.
5. Enable Developer Mode or trust the developer profile if iOS requests it.

Do not share signing certificates, provisioning profiles, Apple ID passwords or private keys with anyone.
