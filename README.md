# UBcards for Ubuntu-Touch (UBports)

***This application is still in testing, please comment on existing issues or open a new one if something goes wrong, if you found a bug, or if you wish a new feature.***

UBcards is a simple card wallet application for [Ubuntu Touch](https://ubports.com/). UBcards allows managing the barcode-based (loyalty) cards. Cards could be scanned by the phone camera or inserted manually.

UBcards follows the philosophy of the older [Card Wallet](https://gitlab.com/AppsLee/cardwallet) application, preserving its simplicity, while adding few new features like icons for easier view in the longer card list, or direct barcode scanning. 

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/ubcards)

[![UBcards](https://github.com/belohoub/UBcards/blob/master/app/graphics/ubcards256.png?raw=true)](https://github.com/belohoub/UBcards/)

## Import/Export

UBcards allows to import/export cards from/to another apps by employing simple scripts.
Currently, UBcards allows migration from the older Ubuntu-Touch Card Wallet application and the well-known Android [Catima](https://catima.app/).

### Migrating from the Card Wallet App

UBcards allows you to import your cards from the Card Wallet application if you come from Xenial to Focal using a simple shell script.

The migration is allowed by the shell script, not by the UI. This is because the application isolation complicates the implementation and yes, I'm lazy, and I hope this one-time step is OK for most users :-) 

To import cards from the Card Wallet app, execute the following script on your Ubuntu-Touch device:
```
$ cat ~/.local/share/ubcards/wallet.ini
$ bash /opt/click.ubuntu.com/ubcards/current/import/import_cardwallet.sh 
Create a backup of the wallet: 
Getting data from the Card Wallet: 
  - processing: Tesco, ... , 1, CODE-128
  - processing: Billa, ... , 3, EAN-13
  - processing: Sportisimo, ... , 3, EAN-13
  - processing: IEEE, ... , 6, CODE-39
Done!
$ cat ~/.local/share/ubcards/wallet.ini
```

Then re-open the UBcards app and check if the import was successful. 
In case of any issues, you can return to the previous configuration:

```
$ cp ~/.local/share/ubcards/wallet.ini~ ~/.local/share/ubcards/wallet.ini
```

### Importing Data from Catima

First, you need to export data from the Catima app. The *catima.zip* fle is created.
Unzip this file and transfer file *catima.csv* to your Ubuntu-Touch device.

To import cards from the Card Wallet app, execute the following script in the directory, where *catima.csv* is located, on your Ubuntu-Touch device:
```
$ cat ~/.local/share/ubcards/wallet.ini
$ bash /opt/click.ubuntu.com/ubcards/current/import/import_catima.sh 
Create backup of the wallet: 
Importing data from the catima.csv: 
  - processing: 1, Clothing Store, qw, , CODE-128
  - processing: 2, Department Store, A, , CODE-128
  - processing: 3, Grocery Store, dhd, , CODE-128
  - processing: 4, Pharmacy, dhshsvshs, , CODE-128
  - processing: 5, Restaurant, 98765432, CODE_128, CODE-128
  - processing: 6, Shoe Store, zhxbx, CODE_39, CODE-39
  - processing categories: 8, shopping
  - processing categories: 3, restaurant
  - processing categories: 4, health
  - processing categories: 5, restaurant
  - processing categories: 6, shopping
Done!
$ cat ~/.local/share/ubcards/wallet.ini
```

Then re-open the UBcards app and check if the import was successful. 
In case of any issues, you can return to the previous configuration:

```
$ cp ~/.local/share/ubcards/wallet.ini~ ~/.local/share/ubcards/wallet.ini
```

### Exporting Data for Catima
To export *catima.zip*, which could be imported by Catima, execute the following script on your Ubuntu-Touch device:

```
$ cat ~/.local/share/ubcards/wallet.ini
$ bash /opt/click.ubuntu.com/ubcards/current/import/export_catima.sh 
Importing data from the wallet.ini: 
Procesing Card ID: 1
Procesing Card ID: 2
Procesing Card ID: 3
Procesing Card IDs' category: 1
Procesing Card IDs' category: 2
Procesing Card IDs' category: 3
Creating catima.zip file:
Done!
$ cat ~/.local/share/ubcards/wallet.ini
```

Now transfer the *catima.zip** file to a device with Catima and import it in the Catima app.


## Project History

UBcards follows the philosophy of the older [Card Wallet](https://gitlab.com/AppsLee/cardwallet) application, preserving its simplicity, while adding a few new features like icons for easier view in the longer card list, or direct barcode scanning. 

The subset of Card Wallets' code is re-used in UBcards, while UBcards is the extensively reworked fork of the [Tagger](https://gitlab.com/balcy/tagger) application from which it inherits e.g. the barcode scanning features.

The overall code evolution is briefly documented in the [changelog](CHANGELOG.md).

## Credits

I would like to thank several projects/persons:
1. [Tagger](https://gitlab.com/balcy/tagger) for a great application. This app is actually a fork of Tagger
1. [Card Wallet](https://gitlab.com/AppsLee/cardwallet) for a great application, re-used code snippets, and fonts
1. [Fonticons, Inc.](https://fontawesome.com) for the Font Awesome Icons
1. [Sam Hewitt, Suru Icons](https://github.com/snwh/suru-icon-theme) for the initial graphics used to create the application logo
1. [UBsync](https://github.com/belohoub/UBsync/) for experience with development for Ubuntu-Touch

### Current and Past Contributors
  * [Jan Belohoubek](https://github.com/belohoub/)

## Contribute

Please use the [issue tracker](https://github.com/belohoub/UBcards/issues) to report a bug or request a new feature.
Any help on the code is welcome to enhance the app!

The code is currently still filled by the unnecessary code inherited from the Tagger - it will need further cleanup.

Please see the following issues to discuss the proposed features:
  * The general discussion about the set of [card cathegories](https://github.com/belohoub/UBcards/issues/1)
  * Highlight the [favorite and/or most used cards](https://github.com/belohoub/UBcards/issues/2)

### Translations

For translation instructions please read this page from the [docs](https://docs.ubports.com/en/latest/contribute/translations.html).

In short, this app currently does not use a translation service. So you will need to either create or edit the *.po* file for your language and commit this new/changed *.po* file as a pull request.

### Documentation
  * [BUILD.md](BUILD.md)
