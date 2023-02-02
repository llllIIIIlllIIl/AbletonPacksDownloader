
# AbletonPacksDownloader

AbletonPacksDownloader is a very simple script related on the use of wget helping to download Ableton .alp packs using direct links without an Ableton account. 

## Linux

### Installation

```bash
apt-get install wget git
git clone https://github.com/llllIIIIlllIIl/AbletonPacksDownloader/
```

### Usage

```bash
cd AbletonPacksDownloader/
./AbletonPacksDownloader.sh
```


## Windows

### Installation

For now on windows you can bulk download all packs using a wget binary. And then run the command bellow.

### Usage

```bash
wget.exe -i https://raw.githubusercontent.com/llllIIIIlllIIl/AbletonPacksDownloader/main/URLs-list.txt
```

## To Do

Windows version using powershell.
Make a fonction to add new URLs using coockies of a paid ableton suite account. 

## Contributing

Pull requests are welcome, mainly to update the URLs list. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

Need to learn what license is the best

In the meantime license is:
[MIT](https://choosealicense.com/licenses/mit/)
