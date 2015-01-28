# protractor-trials
Running some trials with protractor to prove I can mock data per test case

#### How Does It Work?

##### The Portal :panda_face:
-----------------------------

If you’ve been a Web Driver user long enough, you know that you can emit arbitrary machinery
at runtime. With this hook, the possibilities are limitless. This is what I like to call “the
portal”. It’s like this hole in your browser that allows custom JavaScript to make it’s way
through...at will. `kbaltrinic/http-backend-proxy` is leveraging this feature of Web Driver and
as a result....well....we’re Gucci.

##### This Is JavaScript....Man :running:
-----------------------------------------

When I first started to consume `kbaltrinic/http-backend-proxy`, my head exploded. I saw stray
references to `$httpBackend`, and I wondered where they came from. Did his API provided them?
Did protractor provide it? This all being in the context of node as that’s where your tests
drive the UI from. I would type out what I saw verbatim on the screen, and bang...reference error.
I’m like hwa? How can this be? I scanned his doc over and over again, and my epiphany was born. Remember
the first section where I reference “the portal”? `http-backend-proxy` takes your callbacks, serializes
them, and publishes them to the browser’s context (as if it was originally included in your app all along).
Kool, weird, and kinda freaky. If this were .NET, we’d be screwed. csc (the compiler) would start doing it’s thing and
yell at us about some type or variable not being defined. However, “this is JavaScript...man”. The neat
thing about callbacks is that they aren’t executed until....they’re executed. Some code somewhere
has to invoked your callback, or it’ll never run. It’s kinda scary if you think about it. Because
if a callback contained a bug, you’d never see it unless the callback were triggered (chances are...it would be).
Let me give you an example to illustrate my point:

```
function test(fn) { fn() }

test(function() { cons.long('hi there'); })

ReferenceError: cons is not defined
```

See that? I purposely misspelled console and it bombed out. Watch what happens when I update `test` to not invoke
it’s callback:

```
function test(fn) { console.log('not invoking callback. just koolin.') }

test(function() { cons.long('hi there'); })
undefined
"not invoking callback. just koolin."
```

See? No reference error there. Firefox’s console spits out the return value of the function (`undefined`), and
logs some text to the console. But all clear (no erors). This is how code [like this works](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/github-api-mock.e2e.coffee).

If you take a look there, you’ll see that `$httpBackend` is being referenced in the callback. It isn’t defined anywhere though,
not even globally. `http-backend-proxy` will serialize that guy, and by the time it’s run in the browser, your app will be expected
to have loaded `$httpBackend` via `ngMockE2E`. That’s how this all works...man. `http-backend-proxy` is basically just a library that
emits code based on angular and `$httpBackend`. It makes it look as if that code were in your app the entire time (dynamically spits it out).
Notice the word “serialize”. Your callback isn’t being invoked directly, but rather converted into a string and sent off to Web Driver.
I can’t underscore this enough. Once this settles into the pores of your memory banks, life gets that much easier.

##### Dependencies :rage:
-------------------------

`ngMockE2E` and `angular-mocks` are required for all this magic to work. That means somewhere you’ll have to write code like
[this](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/core/app.coffee#L7).
You build process would also have to inject `angular-mocks` into the page. Why is all this necessary? Because that’s where
`$httpBackend resides`...inside `angular-mocks`. Simple enough right? Well...the problem is...if your app just blindly relies
upon `ngMockE2E` it’s going to fail under general usage (when you’re not running tests in the context of protractor). This
is because `$httpBackend` expects requests for each url to be configured. When I load my app outside protractor, I get something
like:
```
"Error: Unexpected request: GET https://api.github.com/users/armw4
No more request expected
$httpBackend@http://localhost:3000/angular-mocks/angular-mocks.js:1226:1
sendReq@http://localhost:3000/angular/angular.js:9619:1
$http/serverRequest@http://localhost:3000/angular/angular.js:9335:16
```

Hence the birth of [#2](https://github.com/armw4/protractor-trials/issues/1). Now..you could have your app just kinda
hack `$httpBackend` and do a pass through for all requests when your’re not running protractor, but I would not recommend
that. I would say go all or nothing. Exclude `ngMockE2E` and `angular-mocks` all together when not running e2e tests. However
you decide to skin this cat is of course up to you. I’m just the messenger...you know the drill.

##### The Base Constructs :facepunch:
-------------------------------------

I’ve already [written](https://github.com/armw4/github-features#why-page-objects) about the [use of page objects](https://github.com/armw4/github-features#are-page-objects-ubiquitous)
and why I believe in them. So no need to beat that horse, it died already. I just wanted to make it clear that they’re being used here.
If I’m gonna do this fulls scale (as is the plan for our internal application), I’d want to make use of two basic constructs:

* [page objects](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/home/home-page.e2e.coffee)
* [mock configuration objects](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/github-api-mock.e2e.coffee)

And these guys:

* [json](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/armw4-github-payload-1.e2e.json) [fixtures](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/armw4-github-payload-2.e2e.json)

These guys will dry things up quite a bit and encapsulate a lot of boilerplate. This, combined with the aesthetically pleasing and
Ruby-esque syntax of Coffee Script make for one hell of a show. It puts the fun back in e2E for angular apps in my mind.

##### Page Load vs Everything Else :dolls:
------------------------------------------

I spent hours trying to figure out why my specs were failing. Then I saw [this](https://github.com/kbaltrinic/http-backend-proxy/blob/8f1c650250d01109c61265df4e4f35ea9ee39f09/test/e2e/onLoad-spec.js#L27https://github.com/kbaltrinic/http-backend-proxy/blob/8f1c650250d01109c61265df4e4f35ea9ee39f09/test/e2e/onLoad-spec.js#L27).
There’s the concept of "on load" configurations. Basically if when you initially load your pages, and requests are triggered without
any user interaction (bootstrapping for example), then you will want to [register these guys for onLoad like so](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/github-api-mock.e2e.coffee#L8).
The first thing that happens when my page loads is a request to the github API. If I were to remove that call to `@proxy.onLoad`,
my specs would fail. Everything else will pretty much be a barebones configuration. You’d just skip the call to onLoad like
[this guy](https://github.com/kbaltrinic/http-backend-proxy/blob/5b52ef02909c49d1dc6d46ac6303f044e4c2891e/test/e2e/proxy-when-spec.js#L91).
Most requests to a remote server will require some sort of user interaction (i.e. button click) before they’re initiated. That’s
what I consider to be the “Everything Else” category.

##### Close Em’ :airplane:
--------------------------

Well...I think that’s pretty much all you need to know in order to get up and running with this bad boy. I would recommend heading
over to the `kbaltrinic/http-backend-proxy` README for more details. It’s there that you’ll find out the usage and importance of the
[`context` object](https://github.com/armw4/protractor-trials/blob/d4ffce249223a0ba3016982449e7f3289097887d/client/github/github-api-mock.e2e.coffee#L5) for example.
I think this project is really kool and it’s gonna serve as another one of my swiss army knives. As always...

> ***Roll em’...***

:fries: :coffee: :rugby_football: :calendar: :euro: :tv: :school_satchel: :bamboo: :full_moon_with_face: :boar: :suspect: :muscle:
:sweat_drops: :collision: :joy: :stuck_out_tongue_winking_eye: :crocodile: :bouquet: :water_buffalo: :hatching_chick: :racehorse:
:turtle: :tanabata_tree: :fries: :coffee: :rugby_football: :calendar: :euro: :tv: :school_satchel: :bamboo: :full_moon_with_face: :boar: :suspect: :muscle:
:sweat_drops: :collision: :joy: :stuck_out_tongue_winking_eye: :crocodile: :bouquet: :water_buffalo: :hatching_chick: :racehorse:
