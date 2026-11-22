extends RefCounted
class_name MatchFixture

var round_name: String = ""
var date: String = ""
var time: String = ""
var home_team: String = ""
var away_team: String = ""
var home_goals: int = -1
var away_goals: int = -1
var played: bool = false

static func from_openfootball(data: Dictionary) -> MatchFixture:
	var fixture := MatchFixture.new()
	fixture.round_name = str(data.get("round", ""))
	fixture.date = str(data.get("date", ""))
	fixture.time = str(data.get("time", ""))
	fixture.home_team = str(data.get("team1", ""))
	fixture.away_team = str(data.get("team2", ""))

	var score_data: Variant = data.get("score", null)
	var full_time: Variant = null
	if score_data is Dictionary:
		full_time = score_data.get("ft", null)
	elif score_data is Array:
		full_time = score_data

	if full_time is Array and full_time.size() >= 2:
		fixture.home_goals = int(full_time[0])
		fixture.away_goals = int(full_time[1])
		fixture.played = true

	return fixture

func to_dictionary() -> Dictionary:
	return {
		"round": round_name,
		"date": date,
		"time": time,
		"home_team": home_team,
		"away_team": away_team,
		"home_goals": home_goals,
		"away_goals": away_goals,
		"played": played
	}
