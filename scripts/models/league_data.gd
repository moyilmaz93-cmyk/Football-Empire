extends RefCounted
class_name LeagueData

var name: String = ""
var season: String = ""
var source_url: String = ""
var fixtures: Array[MatchFixture] = []

static func from_openfootball(data: Dictionary, season_id: String, url: String) -> LeagueData:
	var league := LeagueData.new()
	league.name = str(data.get("name", "Bilinmeyen lig"))
	league.season = season_id
	league.source_url = url

	var raw_matches: Variant = data.get("matches", [])
	if not raw_matches is Array:
		return league

	for raw_match in raw_matches:
		if raw_match is Dictionary:
			league.fixtures.append(MatchFixture.from_openfootball(raw_match))
	return league

func get_team_names() -> Array[String]:
	var teams: Array[String] = []
	for fixture in fixtures:
		if not teams.has(fixture.home_team):
			teams.append(fixture.home_team)
		if not teams.has(fixture.away_team):
			teams.append(fixture.away_team)
	teams.sort()
	return teams

func get_standings() -> Array[Dictionary]:
	var table: Dictionary = {}
	for team_name in get_team_names():
		table[team_name] = {
			"team": team_name, "played": 0, "won": 0, "drawn": 0, "lost": 0,
			"gf": 0, "ga": 0, "gd": 0, "points": 0
		}

	for fixture in fixtures:
		if not fixture.played:
			continue
		var home: Dictionary = table[fixture.home_team]
		var away: Dictionary = table[fixture.away_team]
		home.played += 1
		away.played += 1
		home.gf += fixture.home_goals
		home.ga += fixture.away_goals
		away.gf += fixture.away_goals
		away.ga += fixture.home_goals
		if fixture.home_goals > fixture.away_goals:
			home.won += 1
			home.points += 3
			away.lost += 1
		elif fixture.home_goals < fixture.away_goals:
			away.won += 1
			away.points += 3
			home.lost += 1
		else:
			home.drawn += 1
			away.drawn += 1
			home.points += 1
			away.points += 1

	var standings: Array[Dictionary] = []
	for team_name in table.keys():
		var row: Dictionary = table[team_name]
		row.gd = row.gf - row.ga
		standings.append(row)
	standings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.points != b.points:
			return a.points > b.points
		if a.gd != b.gd:
			return a.gd > b.gd
		if a.gf != b.gf:
			return a.gf > b.gf
		return str(a.team) < str(b.team)
	)
	return standings
