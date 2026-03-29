# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  "Restaurant",
  "Convenience Store",
  "Cafe",
  "Izakaya",
  "Train Station",
  "Hotel",
  "Pharmacy",
  "Post Office",
  "Bank",
  "Supermarket",
  "Travel",
  "Shopping"
].each do |name|
  Context.find_or_create_by!(name: name)
end

[
  { english: "I drink water.",          japanese: "私は水を飲みます。" },
  { english: "I eat rice.",             japanese: "私はご飯を食べます。" },
  { english: "I study Japanese.",       japanese: "私は日本語を勉強します。" },
  { english: "I go to school.",         japanese: "私は学校に行きます。" },
  { english: "My friend reads books.",  japanese: "友達は本を読みます。" },
  { english: "I drink coffee at home.", japanese: "私は家でコーヒーを飲みます。" },
  { english: "I watch TV tonight.",     japanese: "今夜テレビを見ます。" },
  { english: "I eat sushi.",            japanese: "私は寿司を食べます。" },
  { english: "I study at home.",        japanese: "私は家で勉強します。" },
  { english: "I read a book.",          japanese: "私は本を読みます。" }
].each do |attrs|
  TranslationSentence.find_or_create_by!(english: attrs[:english]) do |s|
    s.japanese = attrs[:japanese]
  end
end
