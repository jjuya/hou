# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  email: "asdf@asdf.com",
    password: "123123",
    password_confirmation: "123123"
)

3.times do
  Board.create(
    title: Faker::LeagueOfLegends.champion,
    starred: true,
    user_id: 1
  )
end

2.times do
  Board.create(
    title: Faker::LeagueOfLegends.champion,
    starred: false,
    user_id: 1
  )
end

5.times do |i|
  List.create(
    title: "No title",
    board_id: i
  )
end

10.times do |i|
  List.create(
    title: Faker::LeagueOfLegends.rank,
    board_id: (1..5).to_a.sample()
  )
end

20.times do |i|
  Bookmark.create(
    title: Faker::LeagueOfLegends.masteries,
    url: Faker::Internet.url,
    description: Faker::LeagueOfLegends.quote,
    tag_1: Faker::Food.dish,
    tag_2: Faker::Food.dish,
    tag_3: Faker::Food.dish,
    rating: (0..5).to_a.sample(),
    list_id: (1..15).to_a.sample()
  )
end
