#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
	mkdir -p t/a t/b
	touch t/a/e
	touch t/b/f
	echo -en "ABCDEF" > t/a/a
	echo -en "ABCCEF" > t/b/b
	echo -en "AAAAAA" > t/b/c
	echo -en "AACDEE" > t/b/d
	echo -en "AAAAAAAAAAAAAAAAA" > t/b/z
	head -c 4096 /dev/zero > t/a/4
}

teardown() {
	cat t/trace.log
	rm -rf t/  # commentez pour garder les artefacts de tests
	true
}

# Lancer les tests avec `BATS_VALGRIND` active la detection des fuites
if [[ -n "$BATS_VALGRIND" ]]; then
	eval orig_"$(declare -f run)"
	run() {
		orig_run valgrind -q --leak-check=full "$@"
	}
fi

trun() {
	run ./inject "$@" 3>t/trace.log
	trace=`cat t/trace.log`
	trace=`echo $trace`
}

tsrun() {
	run --separate-stderr ./inject "$@" 3>t/trace.log
	trace=`cat t/trace.log`
	trace=`echo $trace`
}


@test "usage ok simple: lcp fichier fichier" {
	trun ./lcp t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "usage nok mauvais narg: lcp a" {
	tsrun ./lcp t/a/a
	[ "$status" -ne 0 ]
	[ "$stderr" != "" ]
}

@test "usage nok mauvais arg: -c" {
	tsrun ./lcp -c t/a/a t/b/a
	[ "$status" -ne 0 ]
	[ "$stderr" != "" ]
}

@test "usage nok mauvais arg: -b NaN" {
	tsrun ./lcp -b abc t/a/a t/b/a
	[ "$status" -ne 0 ]
	[ "$stderr" != "" ]
}

@test "usage nok mauvais arg: lcp -b sans src dst" {
	tsrun ./lcp -b 2
	[ "$status" -ne 0 ]
	[ "$stderr" != "" ]
}

@test "usage nok mauvais arg: lcp -b src dst" {
	tsrun ./lcp -b t/a/a t/a/a
	[ "$status" -ne 0 ]
	[ "$stderr" != "" ]
}

@test "usage nok b zero: lcp -b 0 src dst" {
	tsrun ./lcp -b 0 t/a/a t/a/a
	[ "$status" -ne 0 ]
	[[ "$stderr" = *"negatif ou nul"* ]]
}

@test "usage nok b impair: lcp -b 1 src dst" {
	tsrun ./lcp -b 1 t/a/a t/a/a
	[ "$status" -ne 0 ]
	[[ "$stderr" == *"pair"* ]]
}

@test "usage ok b pair: lcp -b 2 src dst" {
	trun ./lcp -b 2 t/a/a t/a/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "bloc size read: lcp -b 2 src dst" {
	trun ./lcp -b 2 t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
	[[ "$trace" =~ read\(2\) ]]
}

@test "bloc size write: lcp -b 2 src dst" {
	trun ./lcp -b 2 t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
	[[ "$trace" =~ write\(2\) ]]
}

@test "src empty" {
	trun ./lcp t/a/e t/b/e
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/e t/b/e
}

@test "multiple src bad dst: dst_is_file" {
	trun ./lcp t/a/a t/a/e t/b/f
	[ "$status" -ne 0 ]
}

@test "multiple src bad dst: dst_is_missing" {
	trun ./lcp t/a/a t/a/e t/b/g
	[ "$status" -ne 0 ]
}

@test "dest file not exists" {
	trun ./lcp -b 6 t/a/a t/b/
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "dest dir" {
	trun ./lcp -b 2 t/a/a t/b
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "dest dir (trailing slash)" {
	trun ./lcp -b 2 t/a/a t/b/
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "dest 1 bloc diff" {
	TRACEALL=1 trun ./lcp -b 2 t/a/a t/b/b
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/b
	[[ "$trace" =~ write\(2\) ]]
	[[ "$trace" =~ (.*write.*){1} ]]
}

@test "dest many bloc diff" {
	TRACEALL=1 trun ./lcp -b 2 t/a/a t/b/d
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/d
	[[ "$trace" =~ write\(2\) ]]
	[[ "$trace" =~ (.*write.*){2} ]]
}

@test "dest diff" {
	trun ./lcp t/a/a t/b/c
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/c
}

@test "dest nodiff" {
	cp t/a/a t/b/a
	TRACEALL=1 trun ./lcp t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
	[[ ! "$trace" =~ write ]]
}

@test "bloc misalign" {
	trun ./lcp -b 4 t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "bloc large" {
	trun ./lcp -b 1024 t/a/a t/b/a
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/a
}

@test "dst larger" {
	trun ./lcp t/a/a t/b/z
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
	diff t/a/a t/b/z
}
