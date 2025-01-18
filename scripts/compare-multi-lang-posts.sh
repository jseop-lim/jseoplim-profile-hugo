#!/bin/bash

# posts 디렉터리 경로
POSTS_DIR="content/posts"

# 다르지 않은 파일 개수와 다른 파일 개수를 저장할 변수
same_count=0
diff_count=0

# 모든 하위 디렉터리 탐색
while IFS= read -r dir; do
    # 디렉터리 내 파일 경로
    en_file="$dir/index.en.md"
    ko_file="$dir/index.ko.md"

    # 두 파일이 모두 존재하는지 확인
    if [[ -f "$en_file" && -f "$ko_file" ]]; then
        # 파일 내용 비교
        if cmp -s "$en_file" "$ko_file"; then
            # 다르지 않은 파일 개수 증가
            same_count=$((same_count + 1))
        else
            # 다를 경우 디렉터리 경로 출력
            echo "$dir"
            # 다른 파일 개수 증가
            diff_count=$((diff_count + 1))
        fi
    fi
done < <(find "$POSTS_DIR" -type d)

# 결과 출력
echo "$diff_count different, $same_count same files found."
