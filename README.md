# Titlizer

## Requirements
  Ruby >= 3.0 
## Usage

```bash
$ bundle install
$ exe/titlizer https://onlinesbi.com https://spotify.com https://ifeng.com \
https://soundcloud.com https://bbc.co.uk https://w3schools.com https://globo.com \
https://fc2.com https://ebay.co.uk https://youdao.com https://mercadolivre.com.br


+-----------------------------+--------+----------------------------------+--------------------------------------------------------------------------------+
|                                                                         Results                                                                          |
+-----------------------------+--------+----------------------------------+--------------------------------------------------------------------------------+
| site                        | status | last_location                    | title                                                                          |
+-----------------------------+--------+----------------------------------+--------------------------------------------------------------------------------+
| https://onlinesbi.com       | ok     | https://onlinesbi.com            | State Bank of India                                                            |
| https://spotify.com         | ok     | https://www.spotify.com/ru-ru/   | Услышать весь мир - Spotify                                                    |
| https://ifeng.com           | ok     | https://www.ifeng.com/           | 凤凰网                                                                            |
| https://soundcloud.com      | ok     | https://soundcloud.com           | SoundCloud – Listen to free music and podcasts on SoundCloud                   |
| https://bbc.co.uk           | ok     | https://www.bbc.co.uk/           | BBC - Home                                                                     |
| https://w3schools.com       | ok     | https://www.w3schools.com/       | W3Schools Online Web Tutorials                                                 |
| https://globo.com           | ok     | https://www.globo.com/           | globo.com - Absolutamente tudo sobre notícias, esportes e entretenimento       |
| https://fc2.com             | ok     | https://fc2.com                  | FC2 - Free Website, Analyzer, Blog, Rental Server, SEO Countermeasures, etc. - |
| https://ebay.co.uk          | ok     | https://www.ebay.co.uk/          | Electronics, Cars, Fashion, Collectibles & More | eBay                         |
| https://youdao.com          | ok     | https://youdao.com               | 有道首页                                                                           |
| https://mercadolivre.com.br | ok     | https://www.mercadolivre.com.br/ | Dia das Mães                                                                   |
+-----------------------------+--------+----------------------------------+--------------------------------------------------------------------------------+

```

## TODO:
- [x] Implement Titilizer::Parser
- [x] Implement async
- [x] Implement console
- [x] Add CLI mode
- [ ] Add options to CLI
- [ ] Add specs
- [ ] Speed up with reactors or workers
