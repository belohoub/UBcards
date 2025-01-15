# Changelog

# 0.1.4 (01/2025)

1. Import/Export Cards from/to Catima by means of shell scripts; pictures are currently ignored
2. Code-39 and PICTURE fixes by stevenleadbeater 

# 0.1.3 (04/2024)

1. the card storage process was completely rewritten and simplified to resolve reported issues (history model legacy from the Tagger app has been removed)
2. minor fixes related to the CODE-128
3. CODE-128-mini barcode has been added - this is thge barcode where code types can be mixed to minimize barcode size
4. PICTURE could be selected to show barcode cut from the scanned picture as a last-resort solution, when barcode synthesis does not work correctly
5. minor UI fixes

# 0.1.2 (02/2024)

1. fixes the editing issue: when editing a card, the last added card (card id in the list: 0) was always erased/replaced, not the intended one (issue #9)
2. fixes overflow for long codes under barcode
3. minor UI fixes


# 0.1.1 (07/2023)
1. Minor enhancement of the QR/BAR code display: type-based color frame around the code is displayed; code is always displayed on white background -> UI is now compatible with the suru-dark system theme
2. Clean-up of translatable strings
3. Dutch and Czech translations
4. Xenial backport

# 0.1.0 (06/2023)
1. Initial release created as fork of Tagger and Card Wallet following the Card Wallet philosophy and bringing card-scanning features from Tagger and few other UI elements
