# Seed regions with hierarchy
puts "Seeding regions..."

# Root regions
latinoamerica = Region.find_or_create_by!(code: 'LA') do |r|
  r.name = 'Latinoamerica'
  r.emoji_flag = '🌎'
  r.position = 1
end

espana = Region.find_or_create_by!(code: 'ES') do |r|
  r.name = 'Espana'
  r.emoji_flag = '🇪🇸'
  r.position = 2
end

# Latin American countries
countries = [
  { code: 'MX', name: 'Mexico', emoji_flag: '🇲🇽', position: 1 },
  { code: 'CO', name: 'Colombia', emoji_flag: '🇨🇴', position: 2 },
  { code: 'AR', name: 'Argentina', emoji_flag: '🇦🇷', position: 3 },
  { code: 'CL', name: 'Chile', emoji_flag: '🇨🇱', position: 4 },
  { code: 'PE', name: 'Peru', emoji_flag: '🇵🇪', position: 5 },
  { code: 'VE', name: 'Venezuela', emoji_flag: '🇻🇪', position: 6 },
  { code: 'EC', name: 'Ecuador', emoji_flag: '🇪🇨', position: 7 },
  { code: 'BO', name: 'Bolivia', emoji_flag: '🇧🇴', position: 8 },
  { code: 'PY', name: 'Paraguay', emoji_flag: '🇵🇾', position: 9 },
  { code: 'UY', name: 'Uruguay', emoji_flag: '🇺🇾', position: 10 },
  { code: 'PA', name: 'Panama', emoji_flag: '🇵🇦', position: 11 },
  { code: 'CR', name: 'Costa Rica', emoji_flag: '🇨🇷', position: 12 },
  { code: 'GT', name: 'Guatemala', emoji_flag: '🇬🇹', position: 13 },
  { code: 'HN', name: 'Honduras', emoji_flag: '🇭🇳', position: 14 },
  { code: 'SV', name: 'El Salvador', emoji_flag: '🇸🇻', position: 15 },
  { code: 'NI', name: 'Nicaragua', emoji_flag: '🇳🇮', position: 16 },
  { code: 'DO', name: 'Republica Dominicana', emoji_flag: '🇩🇴', position: 17 },
  { code: 'PR', name: 'Puerto Rico', emoji_flag: '🇵🇷', position: 18 },
  { code: 'CU', name: 'Cuba', emoji_flag: '🇨🇺', position: 19 }
]

countries.each do |country|
  Region.find_or_create_by!(code: country[:code]) do |r|
    r.name = country[:name]
    r.emoji_flag = country[:emoji_flag]
    r.position = country[:position]
    r.parent = latinoamerica
  end
end

puts "Created #{Region.count} regions"
