extends Node

# Loads question packs and serves random questions for the current age group.
# Tries local packs first, then falls back to the API.
# Questions are served without repeating until the whole pool is exhausted.

const API_BASE = "https://play.wambugumartin.com/api"
const LOCAL_PACK_PATH = "res://question_packs/"

signal questions_loaded(questions: Array)
signal question_load_failed(reason: String)

const SUBJECTS = ["math", "literacy", "science"]

var _all_questions: Array = []   # merged pool from all subjects
var _used_indices: Array = []    # indices into _all_questions already shown

func load_all_packs(age_group: String) -> void:
	_all_questions.clear()
	_used_indices.clear()
	for subject in SUBJECTS:
		load_pack(age_group, subject)

func load_pack(age_group: String, subject: String) -> void:
	var folder = "age_" + age_group.replace("-", "_")
	var local_path = LOCAL_PACK_PATH + folder + "/" + subject + ".json"

	if ResourceLoader.exists(local_path):
		_load_local(local_path)
	else:
		_load_remote(age_group, subject)

func _load_local(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		question_load_failed.emit("Cannot open local pack: " + path)
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		question_load_failed.emit("JSON parse error in: " + path)
		return
	_store_questions(json.data.get("questions", []))

func _load_remote(age_group: String, subject: String) -> void:
	var folder = "age_" + age_group.replace("-", "_")
	var url = API_BASE + "/packs/" + folder + "/" + subject
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_remote_loaded.bind(http))
	http.request(url)

func _on_remote_loaded(result: int, _code: int, _headers, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS:
		question_load_failed.emit("Network error fetching questions")
		return
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		question_load_failed.emit("Bad JSON from API")
		return
	_store_questions(json.data.get("questions", []))

func _store_questions(questions: Array) -> void:
	_all_questions.append_array(questions)
	questions_loaded.emit(questions)

func get_random_question() -> Dictionary:
	return get_random_from_all()

func get_random_from_all() -> Dictionary:
	if _all_questions.is_empty():
		return {}
	# Reset when all questions have been shown
	if _used_indices.size() >= _all_questions.size():
		_used_indices.clear()
	var available = range(_all_questions.size()).filter(func(i): return i not in _used_indices)
	var idx = available[randi() % available.size()]
	_used_indices.append(idx)
	return _all_questions[idx]

# Call this when a player answers incorrectly — remove from used so it can repeat sooner
func mark_failed(question: Dictionary) -> void:
	var id = question.get("id", "")
	if id.is_empty():
		return
	for i in range(_all_questions.size()):
		if _all_questions[i].get("id", "") == id:
			_used_indices.erase(i)
			break
