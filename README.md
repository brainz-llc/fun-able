# fun-able

Multiplayer party card game inspired by Cards Against Humanity. Built with Rails 8.

## features

- **real-time multiplayer** - play with friends online
- **custom decks** - create and share your own card decks
- **regional content** - decks tailored for different regions/cultures
- **meme cards** - cards with images and GIFs
- **victory celebrations** - animated GIFs when you win

## tech stack

- Rails 8.1
- Hotwire (Turbo + Stimulus)
- SQLite / PostgreSQL
- Tailwind CSS

## how it works

1. create or join a game
2. each round, one player is the judge
3. judge plays a black card (question/fill-in-the-blank)
4. other players submit white cards (answers)
5. judge picks the funniest answer
6. winner gets a point, next player becomes judge
7. first to target score wins

## setup

```bash
bundle install
bin/rails db:prepare
bin/dev
```

## license

MIT

---

built with fun by [@afmp94](https://github.com/afmp94)
