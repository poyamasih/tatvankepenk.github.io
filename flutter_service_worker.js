'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "2759adc46db44e90a2cc58d74a871e34",
".git/config": "a8a98e0d8882721dc7208d5250531cd7",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "f9a827530af96db54423f960f8f32e9d",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "e2ea3c7ea66d7653651da130e70b6e66",
".git/logs/refs/heads/gh-pages": "e560851d9e35a2796ecb44ad65eaa7ab",
".git/logs/refs/remotes/origin/gh-pages": "49e9efd2897518265524cd20c80d093a",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/10/7bfe1225d9c8dca9454e600692dc3096ca9f8d": "6eb45cb00c5d68b3af75179d367f0018",
".git/objects/19/8d1f6bdf4c1c9cea360e14f7f4ab00b5c7504e": "6e4bbcc1a88fece0d55a36cd88cd3779",
".git/objects/1c/d06639f121ce9c1cbfd6277db6cb7a1c996ad3": "c31e1c3daf3501358f7ed9e4ad7f428d",
".git/objects/1e/f45a76562e23bc8e8bf967f44fea85c86bae6b": "bf7cf8f9575aecb30781d0548938d2e6",
".git/objects/24/18df58e613b2bb72c6e3d52e9f88b37e767170": "ce0335a15299d794fa5b19e06281079b",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/36/a08d2111e65f2af2419731a300a20320f99cd2": "e681dc29597e035ea685cca180f4e9f0",
".git/objects/3b/2aa28ab3e56a2691fc36f2784e3a7bbbb74c87": "fbf6ebbbe72db1c7c201d78ecb774b2f",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/5e4c84d7d43b8f31bd69fc08e2eab6f2a1f287": "05b65849352854574d572c2855acfe70",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/58/df0f32d3582c069ecf63ef74076941c970425d": "89cdaa329e90da0f03c58b0e14935f08",
".git/objects/5a/13bd5a18e506d22647433b1980295ce67bcebe": "50b077c2b68b737800ac0d99a322b746",
".git/objects/5a/f10587512433a55c720db4ef2f550ef3029a3f": "af922ec595ea2a732a34e4f349c715e7",
".git/objects/5d/fcd6a96c822a87b5ed0c29d22252d6b3976869": "445a68546b788f657b68d7299bbeae32",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/66/e2a2d2dea9bc52be5f70c62e9feb58aaa82bdb": "4d351645c59ec7c14d35c3e6873dea34",
".git/objects/69/698f5394df7a1b7e59e657e815b738e578be5b": "1c84792735d30838914d95a0c5633882",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/72/0fc89e3a2cd930cc8d4b30e007bde9cef8fa09": "58263235fe876509ab4cd0dd71cda4ea",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/92/e2aaca0d79ddc17b0d6371da06a914ac139ec0": "6e6cd3adb23bdc2d9e7c101455a37682",
".git/objects/95/f3262874e21bdd275968fbdcfeef8f79a983a2": "390a771b99c6fa5b84c0ca7422e3fc76",
".git/objects/97/16562268b1583abc50bdec6a99d93219162a28": "525d0bfd7e5aa9435f09b0b660448768",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/c6/1f50a94f631c9daccb772a15b997d09a3602bd": "38355a85188ace39b6d9ee479275cb45",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/b242e09575381029deeb72e595850b4f157328": "eb76264bd082ad321e3022a652aecf96",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d8/4882df03d27d591e9e7f409b04cfd6debef3bf": "d5eedda0493a49ca48113462697b4bdd",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/df/5c73d85997e2f3e8324f75d8765e062df6c496": "7fcc4ddbaf7b00e5aa548e36f95e212b",
".git/objects/df/ebde2ac76637aa26cb8f3c6d7c19ca7b8f51ed": "66d5850f2d2a3a94e477ed880015a520",
".git/objects/e3/2f08619c8828bb59c2923dad409b66ea37194e": "3aacd954302e72846ba776c77dcc3374",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/ea/8344646704ed5775e078e6466f234db02d19ff": "754c28cbe0bf5b76960e556dcca17e95",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fc/44e9f21dfd98788e7da106366c984b349694f7": "17bfece67f7d251274f341e2c8108c65",
".git/objects/fe/6e426fa55010bd63a071fd0f823d4fe979a5d4": "762e907e9b7cdd39c74ca762ae9b4bb6",
".git/refs/heads/gh-pages": "5f48c3dd7b4561322fbbbbf13a8a4ab8",
".git/refs/remotes/origin/gh-pages": "5f48c3dd7b4561322fbbbbf13a8a4ab8",
"assets/AssetManifest.bin": "e33c0ad19314226962b8d9e8c628ddf1",
"assets/AssetManifest.bin.json": "a90d9d9248a292d01707a1fdd3c98f57",
"assets/AssetManifest.json": "e289878b4ec10d23919c9ee365702964",
"assets/assets/images/Automatic_Shutter.png": "24a92f918004813044de3a4a8047b394",
"assets/assets/images/Autumatik_rof.png": "efb5fc08f73763ca742e16b2d6b033c4",
"assets/assets/images/bg_dark_stars.png": "47dc4b748486857ac46a1b5f5518990f",
"assets/assets/images/logo.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"assets/assets/images/og-kepenk-image.jpg": "20f7d422fc52656a47ae008adbe1c8c9",
"assets/assets/images/project1.jpg": "143d700b524711917b772fe6b53e0e82",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "6cda9547f10a9021018b0ad82b4be51f",
"assets/images/og-kepenk-image.jpg": "20f7d422fc52656a47ae008adbe1c8c9",
"assets/NOTICES": "64cfcad189375b735cea322fc3c53fbe",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"browserconfig.xml": "2d2875d7eeab3b5c7cc8ee74e59318a3",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"CNAME": "195fbc57d9187ed86cc565c458abddaf",
"favicon.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "2ca09238ea3360baba61d3f0dec00906",
"icons/apple-touch-icon.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/favicon-16x16.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/favicon-32x32.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/Icon-192.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/Icon-512.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/Icon-maskable-192.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/Icon-maskable-512.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"icons/mstile-150x150.png": "1d43b432bbc9bcd07a30fea3da599ba1",
"index.html": "4d9aa5e83ca0be3cc17f86e8923d4fb0",
"/": "4d9aa5e83ca0be3cc17f86e8923d4fb0",
"main.dart.js": "ff41ab5eb6f3e15a5855816d0d56fa65",
"manifest.json": "2d0b31ee788caa40f96553a4a1fd457f",
"robots.txt": "bb235a65c79fd98d45a7184c4f9202ab",
"sitemap.xml": "28507cb418c9ba3b5551ca0a5ef94740",
"version.json": "9ee19be422c873f83d860dee692ab304"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
