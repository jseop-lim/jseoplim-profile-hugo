#!/bin/bash

POSTS_DIR="content/posts"
CATEGORIES_DIR="content/categories"
TAGS_DIR="content/tags"

# 다르지 않은 파일 개수와 다른 파일 개수를 저장할 변수
same_count=0
diff_count=0

compare_pairs_in_tree() {
    local root_dir="$1"
    local en_name="$2"
    local ko_name="$3"

    # 모든 하위 디렉터리 탐색
    while IFS= read -r dir; do
        local en_file="$dir/$en_name"
        local ko_file="$dir/$ko_name"

        # 두 파일이 모두 존재하는지 확인
        if [[ -f "$en_file" && -f "$ko_file" ]]; then
            # 파일 내용 비교
            if cmp -s "$en_file" "$ko_file"; then
                same_count=$((same_count + 1))
            else
                echo "$dir"
                diff_count=$((diff_count + 1))
            fi
        fi
    done < <(find "$root_dir" -type d)
}

compare_pairs_in_tree "$POSTS_DIR" "index.en.md" "index.ko.md"
compare_pairs_in_tree "$CATEGORIES_DIR" "_index.en.md" "_index.ko.md"
compare_pairs_in_tree "$TAGS_DIR" "_index.en.md" "_index.ko.md"

# 결과 출력
echo "$diff_count different, $same_count same files found."
