# Seed victory GIFs
puts "Seeding victory GIFs..."

round_win_gifs = [
  "https://media.giphy.com/media/3o6ZtpxSZbQRRnwCKQ/giphy.gif", # Celebration
  "https://media.giphy.com/media/artj92V8o75VPL7AeQ/giphy.gif", # Winner
  "https://media.giphy.com/media/26u4cqiYI30juCOGY/giphy.gif", # Applause
  "https://media.giphy.com/media/3o7abKhOpu0NwenH3O/giphy.gif", # Dance
  "https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif", # Party
  "https://media.giphy.com/media/26BRBKqUiq586bRVm/giphy.gif", # Yes!
  "https://media.giphy.com/media/3oz8xAFtqoOUUrsh7W/giphy.gif", # Happy
  "https://media.giphy.com/media/26tPplGWjN0xLybiU/giphy.gif", # Cheering
]

game_win_gifs = [
  "https://media.giphy.com/media/26u4lOMA8JKSnL9Uk/giphy.gif", # Champion
  "https://media.giphy.com/media/3o7btXkbsV26U95Uly/giphy.gif", # Trophy
  "https://media.giphy.com/media/l0Iy6R0HxIBLBG6jK/giphy.gif", # Fireworks
  "https://media.giphy.com/media/26u4nJPf0JtQPdStq/giphy.gif", # Victory
  "https://media.giphy.com/media/3o6gDWzmAzrpi5DQU8/giphy.gif", # Confetti
  "https://media.giphy.com/media/26BRBPVfvbBhNjGxi/giphy.gif", # The best
  "https://media.giphy.com/media/l41YqKTI3pFKuI9CE/giphy.gif", # Winner dance
]

round_win_gifs.each do |url|
  VictoryGif.find_or_create_by!(url: url) do |gif|
    gif.source = 'giphy'
    gif.category = :round_win
  end
end

game_win_gifs.each do |url|
  VictoryGif.find_or_create_by!(url: url) do |gif|
    gif.source = 'giphy'
    gif.category = :game_win
  end
end

puts "Created #{VictoryGif.count} victory GIFs"
