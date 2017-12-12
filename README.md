# kifulog
Kifulog is a simple command line tool for Kifu. It handles Kifu data saved in BigQuery easily and useful.

## Usage

```
bundle install
```

### Game list

```
bundle exec ruby kifulog.rb game [start_daate] [end_date]
```

*ex.*
```
bundle exec ruby kifulog.rb game 20171201 20171207
```

### Game detail

```
bundle exec ruby kifulog.rb show [start_daate] [end_date] [game_code]
```

*ex.*
```
bundle exec ruby kifulog.rb show 20171201 20171207 ewqfnna
```


### Search castle

```
bundle exec ruby kifulog.rb castle [start_daate] [end_date] [game_code]
```

*ex.*
```
bundle exec ruby kifulog.rb castle 20171201 20171207 mino
```

Now is only MinoCastle.
