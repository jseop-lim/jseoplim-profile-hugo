# Jeongseop Lim's Profile Website

[![Hugo](https://img.shields.io/badge/hugo-v0.152.2-ff4088?style=flat-square&logo=hugo&logoColor=white)](https://gohugo.io/) [![Netlify Status](https://api.netlify.com/api/v1/badges/db81fa40-6297-411f-a24a-499a84859294/deploy-status)](https://app.netlify.com/sites/jseoplim-profile-hugo/deploys)

The website is built using [Hugo](https://gohugo.io/), created with the [DoIt Theme](https://github.com/HEIGE-PCloud/DoIt), and deployed via [Netlify](https://www.netlify.com/).

:link: [about.jseoplim.com](https://about.jseoplim.com/)

## Installation

1. Install [Hugo](https://gohugo.io/getting-started/installing/).

    ```shell
    brew install hugo
    ```

2. Clone this repository.

    ```shell
    git clone https://github.com/jseop-lim/jseoplim-profile-hugo.git
    ```

3. Change directory to the repository.

    ```shell
    cd jseoplim-profile-hugo
    ```

## Workflow

1. Modify the content.

2. Run the server to see the changes locally.

    ```shell
    hugo server -D
    ```

3. Commit and push the changes to the remote `develop` branch.

    ```shell
    git add .
    git commit -m "Update content"
    git push origin develop
    ```

4. Create a pull request to merge the `develop` branch into the `main` branch, and inspect the preview provided by Netlify.

5. Merge the pull request, and check the deployed [website](https://about.jseoplim.com/).

6. If a new post has been added, visit the [Korean site](https://about.jseoplim.com/ko/) after deployment and leave a relaction. A [GitHub discussion](https://github.com/jseop-lim/jseoplim-profile-hugo/discussions/categories/comments) will be created by [giscus](https://giscus.app/).
