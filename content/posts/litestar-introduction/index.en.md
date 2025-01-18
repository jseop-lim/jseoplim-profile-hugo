+++
draft = false

title = "Litestar, 새롭고 빠른 Python API 프레임워크"
date = 2023-09-23
authors = ["Jeongseop Lim"]
description = "Litestar 붐은 온다"

tags = ["Python", "Litestar", "Starlite", "FastAPI", "backend", "framework"]
categories = ["explanation"]
series = []
series_weight = 1

featuredImage = "thumbnail.png"
lightgallery = false
+++

<!--more-->

> [!NOTE]
> [Litestar 공식 홈페이지](https://litestar.dev/)

## FastAPI 이야기

회사에서는 주로 Django와 Django REST framework를 사용 중이나, 요즘 개인 공부의 일환으로 FastAPI를 써보고 있다. FastAPI GitHub를 둘러보다 특이한 사실을 알아냈다. Repository Discussions에 가장 많은 추천을 받은 글이 있는데 도발적인 제목이 눈에 띄었다.

> [Frustrated of FastAPI slow development](https://github.com/tiangolo/fastapi/discussions/3970)

최근 아래와 같은 일을 겪으며 FastAPI의 개발에 대한 의문을 가지고 있었기에, 공감을 느끼며 논의를 구경해보았다.

* 0.100 버전이 배포되었을 때 언제쯤 정식 버전이 출시할까 궁금해졌다.
* 최근에 튜토리얼을 다시 읽으니 올해 초와 내용이 크게 변하여 아직 안정화가 안되었나하는 생각이 들었다. (cf. 큰 변화는 Annotated 도입으로 인한 것임)
* FastAPI에 JWT를 쉽게 쓰도록 돕는 라이브러리(fast-api-auth)를 찾았는데, 라이브러리 제작자는 처음에 같은 기능을 FastAPI에 내재화하는 [PR](https://github.com/tiangolo/fastapi/pull/3305)을 올렸지만 FastAPI 개발자의 답이 없어 별도의 파이썬 패키지로 배포했다.

질문에 대한 FastAPI 원작자의 답변이 인상적이었다. 문서나 번역을 제외하면 FastAPI는 지금까지 소유자 한 명이 최종 작성한 코드로만 구성되어 있었고, 원작자가 확인하지 않은 PR이 열린 채로 쌓이고 있었다. FastAPI의 성장세가 가파르고 직접 써보니 편리한 것은 사실이나, 한 명의 개발자에게 거대한 프로젝트가 의존하는 것은 위험이 커 보인다.

## Litestar 발견

인터넷을 돌아다니니 이러한 FastAPI의 개발 방식에 대해 불만을 품는 이가 적지 않았다. 그러한 누군가가 제시한 대안으로서 Litestar(구 Starlite)를 접하게 되었다. 공식 문서를 찾아보니 FastAPI와 유사한 형태이고 비동기를 전면 지원한다는 장점도 공유했다. 마찬가지로 typing, Pydantic, OpenAPI도 지원한다.

> [!TIP]
> 참고로, Starlite가 원래 프로젝트 이름이었지만, 2.0 버전부터 Litestar로 이름을 바꾸었다. 아직 유명세가 덜하기에 이름 변화가 혼란을 주긴 하나, 훗날 Litestar로 유명해지길 기대한다.

FastAPI와 가장 큰 차이점은 개인 프로젝트가 아닌 단체가 주도한다는 것이다. 실제로 FastAPI에서 개발 방식에 문제를 느낀 사람들이 한 데 모여 시작한 것으로 보인다. 그 외에도 아래 특징이 매력 있었다. 개발 철학은 [공식 문서](https://docs.litestar.dev/latest/#philosophy)에서도 엿볼 수 있다.

### 클래스 기반 컨트롤러

주로 Django와 Django REST framework를 사용하다보니 클래스로 API를 구현하는 것에 익숙하다. 평소 파이썬을 사용하면서도 함수보다 클래스를 선호했으므로 클래스로 컨트롤러를 만든다는 자체가 마음에 든다. 철학에 따르면 코드의 패턴을 제시하는 NestJS에서 영감을 받았다고 한다.

### 복합 기능

마찬가지로 Django 사용자로서 가치를 느끼는 부분이다. Pydantic과 Starlette를 매우 얇게 이어주는 FastAPI와 달리, Litestar는 Starlette에 의존하지 않는 독자적인 API 프레임워크이며 JWT를 포함한 인증이나 DTO 등 자체적인 기능이 다양하다.

### 의존성 주입

FastAPI에서 유일하게 아쉬웠던 기능이 의존성 주입이다. FastAPI가 제공하는 의존성 주입 기능에서는, 의존성를 사용하는 곳(dependant)에서 반드시 callable 형태의 의존성(dependency) 객체를 선언해야 한다. 예를 들어 a.py의 A 객체에서 b.py의 B 객체에 의존한다면, 반드시 a.py에 `from b import B`가 쓰여야 한다. 따라서 a.py와 b.py 간의 소스코드 의존성 역전이 불가능하다. 그래서 개인 프로젝트에서는 별도의 [의존성 주입 프레임워크](https://python-dependency-injector.ets-labs.org/introduction/di_in_python.html)를 결합하여 사용했다.

Litestar는 FastAPI와 같은 방식의 의존성 주입은 물론, 내가 원하는 명시적 의존성 주입 기능도 제공한다.

> [!NOTE]
> [Litestar Documentation > Usage > Dependency Injection](https://docs.litestar.dev/2/usage/dependency-injection.html#)의 예제를 인용

```python {open=true}
from litestar import Controller, Router, Litestar, get
from litestar.di import Provide

async def bool_fn() -> bool:
    ...

class MyController(Controller):
    path = "/controller"

    @get(path="/handler")
    def my_route_handler(
        self,
        app_dependency: bool,
    ) -> None:
        ...

my_router = Router(
    path="/router",
    route_handlers=[MyController],
)

# on the app
app = Litestar(
    route_handlers=[my_router], dependencies={"app_dependency": Provide(bool_fn)}
)
```

만일 `app`와 `bool_fn()`을 `MyController`와 다른 모듈에서 정의한다면, `MyController.my_route_handler()`는 `bool_fn()`에 대해 소스코드 의존성을 가지지 않게 구현할 수 있다.

## 아쉬운 점

아무래도 사용자 수와 그로 인한 정보의 부족이 가장 아쉽다. GitHub Star 수가 62.8K인 FastAPI나 73.2K인 Django에 비해 Litestar의 개수는 그저 2.9K에 불과하다. 또한, FastAPI를 다루면서도 커뮤니티나 서드파티가 Django 비해 모자라다는 것을 체감했는데, Litestar는 그에 비할 바가 못 된다. 2021년 12월에 첫 배포가 이뤄진 신생 프로젝트니 아직 갈 길이 멀다.

## 기대

앞서 언급한 공식 문서의 철학에 따르면 Litestar의 목표는 FastAPI나 Flask 같은 마이크로 프레임워크도, 자체 ORM까지 포함한 Django 같은 초거대 프레임워크도 아니라고 한다. 물론 이도저도 아닌 프레임워크로 남을 수도 있다. 하지만 이미 Pydantic와 function-based endpoints의 조합으로 FastAPI와 같은 기능을 제공하고 있고, ORM이나 serializer 같은 진입 장벽은 없기 때문에 Django의 자리를 넘볼지도 모르겠다.

참고로, GitHub에서 Litestar를 후원하면 자기 계정에 뱃지를 달 수 있다고 하길래 2달러를 후원했다. 내 기대를 충족하도록 성장하길 바란다.

{{< figure src="sponsoring.png" width="400">}}
