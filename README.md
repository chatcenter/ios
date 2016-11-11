# ChatCenteriO iOS SDKインストールガイド Ver. 1.0.7

## Getting Started
### 1. サンプルプロジェクトをダウンロード
[こちら](https://github.com/chatcenter/ios/releases)よりChatCenterSDKをダウンロードします。
Exampleプロジェクトが含まれています。
### 2. Pod install
Exampleフォルダにてpod installを実行してください
### 3. アプリトークンとOrg Uidを設定

![sample1](https://github.com/chatcenter/ios/blob/master/Images/sample1.png)
サンプルプロジェクトを開き、ViewController.m内のアプリトークンとOrg Uidを設定してください。
アプリトークンとOrg Uidはダッシュボードから確認できます。
### 4.　アプリケーションを起動
<img src="https://github.com/chatcenter/ios/blob/master/Images/sample2.png" width="320" height="568">

## SDKをアプリに組み込む
### Xcodeでの設定
#### 1. ソースをプロジェクトに挿入
[こちら](https://github.com/chatcenter/ios/releases)よりChatCenterSDKをダウンロードします。
ChatCenterSDKフォルダを任意のフォルダへドラッグアンドドロップしてください。
#### 2. ライブラリの追加
下記ライブラリを”Build Phases” > ”Link Binary With Libraries”より追加してください。

* UIKit.framework
* CoreGraphics.framework
* AudioToolbox.framework
* QuartzCore.framework
* CFNetwork.framework 
* Security.framework 
* Foundation.framework
* CoreData.framework
* SystemConfiguration.framework
* MobileCoreServices.framework
* libicucore.A.tbdもしくはlibicucore.dylib
* MapKit.framework

#### 3. PCHファイルのパス追加
ChatCenterSDK内にPCHファイルがありますのでパスを通してください。
下図のように、プロジェクト > Build Settings > Apple LLVM 7.0 - Language > Prefix Headerに”(プロジェクト以下のパス)/ChatCenterSDK/ChatCenter.pch”と指定してください。
![pch](https://github.com/chatcenter/ios/blob/master/Images/pch.png)

#### 4. Plistの編集
##### 4-1. ロケーションステッカー
ChatCenter SDKではロケーションステッカーの送信時に、ユーザーの位置情報を使用する機能があります。
そのためInfo.plistに下記のように”NSLocationWhenInUseUsageDescription”の追加をお願いします。設定する文言は任意で構いません(ユーザーに位置情報の許諾を求める際に表示されます)。位置情報の許諾表示は、ユーザーがロケーションステッカーを選択したタイミングで表示されます。

![plist_location](https://github.com/chatcenter/ios/blob/master/Images/plist_location.png)
ソースでは以下のようになります。

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>位置情報を送信時に使用します。</string>
```

##### 4-2. 画像ステッカー
ChatCenter SDKでは画像受信時に、ユーザーがローカルに画像を保存する機能があります。保存時に写真アプリへのアクセス許可を促す必要があるためInfo.plistに追記が必要です。下記のように”NSPhotoLibraryUsageDescription”の追加をお願いします。設定する文言は任意で構いません(ユーザーに写真アプリのアクセス許可を求める際に表示されます)。写真アプリのアクセス許可表示は、ユーザーが画像プレビュー画面で画像を保存するタイミングで表示されます。

![plist_photo](https://github.com/chatcenter/ios/blob/master/Images/plist_photo.png)
ソースでは以下のようになります。

```
<key>NSPhotoLibraryUsageDescription</key>
<string>画像を保存するためにアクセスします</string>
```

#### 5. 言語のローカライズ
各言語のstringファイルを用意しておりますので、各lprojフォルダにstringファイルをコピーしてください。もしlprojフォルダが存在しない場合は、lprojフォルダごとコピーしてください。

```パスの例
ja.lproj/ChatCenterSDK.strings
en.lproj/ChatCenterSDK.strings
```

### ソースコードの挿入
#### 1. App Tokenのセット
以下のメソッドを初回起動時のviewControllerのviewDidLoad等に箇所に挿入ください。
```+ (void)setAppToken:(NSString *)appToken completionHandler:(void (^)(void))completionHandler;```

```例
#import "ChatCenter.h"

- (void)viewDidLoad
{
    [ChatCenter setAppToken:@”appsociallyより発行いたします” completionHandler:^{
       ///セット完了のコールバックです
       ///SDKのデザインカスタマイズはここに記述してください
    }];
  …
  …    
}
```

#### 2. Chat Viewの呼び出し
チャットを表示するChat viewを呼び出します。  
<img src="https://github.com/chatcenter/ios/blob/master/Images/chatview.png" width="375" height="667">

##### 2-1. 認証済みユーザー
以下のコードを任意の場所に挿入してください。

```
- (id)getChatView:(NSString *)orgUid
    firstName:(NSString *)firstName
       familyName:(NSString *)familyName
            email:(NSString *)email
         provider:(NSString *)provider
    providerToken:(NSString *)providerToken
providerTokenSecret:(NSString *)providerTokenSecret
providerCreatedAt:(NSDate *)providerCreatedAt
providerExpiresAt:(NSDate *)providerExpiresAt
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler;
```

##### (a)Facebook認証でのパラメータ
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **orgUid:(NSString *): Chatに紐づく、Organization uidを指定してください**
* firstName:(NSString *): 生成するユーザーのファーストネームを指定してください。nilを指定した場合はFacebookに登録されているユーザーのファーストネームが使用されます。
* familyName:(NSString *): 生成するユーザーのファミリーネームを指定してください。nilを指定した場合はFacebookに登録されているユーザーのファミリーネームが使用されます。
* email:(NSString *): 生成するユーザーのEmailアドレスを指定してください。nilを指定した場合はFacebookに登録されているEmailアドレスが使用されます(Facebook認証時にパーミッションを要求している必要があります)。
* **provider:(NSString *): @”facebook”を指定してください**
* **providerToken:(NSString *): 認証結果のtokenを指定してください**
* providerTokenSecret:(NSString *): nilを指定してください
* providerCreatedAt:(NSDate *): nilを指定してください
* **providerExpiresAt:(NSDate *): 認証結果のtokenの失効日(expirationDate)を指定してください
* deviceToken:(NSString *): プッシュ通知で使用するAppleから取得したdeviceTokenを指定してください
* channelInformations:(NSDictionary *): 生成するchannelに紐づくurlを以下のように指定してください
``例) @{@"url":@"https://app.asana.com"}``

* completionHandler:(void (^)(void))completionHandler:チャット画面を閉じる際に呼ぶコールバック処理を指定してください(画面上部の戻るボタンをカスタマイズした場合にのみ適用されます。カスタマイズについては、8-3. Back button imageをご覧ください)

```例
#import "ChatCenter.h"

…

id chatViewController = [[ChatCenter sharedInstance] getChatView:orgUid
                                                        provider:@”facebook”
                                                   providerToken:token.tokenString 
                                             providerTokenSecret:nil
                                               providerCreatedAt:nil
                                               providerExpiresAt:token.expirationDate
                                             channelInformations:@{@"url":@”http://xxxxxxx”}
                                                     deviceToken:nil
                                               completionHandler:nil];
                                               
 [self.navigationController pushViewController:chatViewController animated:YES];

…
```

##### (b) Twitter認証でのパラメータ
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **orgUid:(NSString *): Chatに紐づく、Organization uidを指定してください**
* firstName:(NSString *): 生成するユーザーのファーストネームを指定してください。familyName:(NSString *): 生成するユーザーのファミリーネームを指定してください。nilを指定した場合はTwitterに登録されているユーザーネームが使用されます。
* email:(NSString *): 生成するユーザーのEmailアドレスを指定してください。
* **provider:(NSString *): @"twitter"を指定してください**
* **providerToken:(NSString *): 認証結果のauthTokenを指定してください**
* **providerTokenSecret:(NSString *):Access token secretを指定してください**
* providerCreatedAt:(NSDate *): nilを指定してください
* providerExpiresAt:(NSDate *): nilを指定してください
* deviceToken:(NSString *): プッシュ通知で使用するAppleから取得したdeviceTokenを指定してください
* channelInformations:(NSDictionary *): 生成するchannelに紐づくurlを以下のように指定してください  
``例) @{@"url":@"https://app.asana.com"}``
* completionHandler:(void (^)(void))completionHandler:チャット画面を閉じる際に呼ぶコールバック処理を指定してください(画面上部の戻るボタンをカスタマイズした場合にのみ適用されます。カスタマイズについては、8-3. Back button imageをご覧ください)

```例
#import "ChatCenter.h"

…

id chatViewController = [[ChatCenter sharedInstance] getChatView:orgUid
												             provider:@”twitter”
												        providerToken:session.authToken
								                  providerTokenSecret:session.authTokenSecret
								                    providerCreatedAt:nil
								                    providerExpiresAt:nil
								                  channelInformations:@{@"url":self.propertyUrl}
								                          deviceToken:nil
								                    completionHandler:nil];
								                    
 [self.navigationController pushViewController:chatViewController animated:YES];

…
```


##### 2-2. 認証なしの場合(Anonymousログイン)
**注意: 認証なしのユーザーに対して、後から認証処理を紐付けることは現在対応しておりません**
以下のコードを任意の場所に挿入してください。

```
- (id)getChatView:(NSString *)orgUid
        firstName:(NSString *)firstName
       familyName:(NSString *)familyName
            email:(NSString *)email
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler;
```

##### パラメータ
太字が必須のパラメータになります(ただしproviderCreatedAt, providerExpiresAtはいづれかを渡してください)。他のパラメータで不要な場合はnilをご指定ください。

* **orgUid:(NSString *): Chatに紐づく、Organization uidを指定してください ※Organization Uid(法人/店舗ID)Iについて**
* firstName:(NSString *): 生成するユーザーのファーストネームを指定してください
* familyName:(NSString *): 生成するユーザーのファミリーネームを指定してください
* email:(NSString *): 生成するユーザーのEmailアドレスを指定してください
* channelInformations:(NSDictionary *): 生成するchannelに紐づくurを以下のように指定してください  
``例) @{@"url":@"https://app.asana.com"}``
* completionHandler:(void (^)(void))completionHandler: チャット画面を閉じる際に呼ぶコールバック処理を指定してください

```例
#import "ChatCenter.h"

…

id chatViewController = [[ChatCenter sharedInstance] getChatView:orgUid
                                                                                              firstName:@”test-first”
                                                                                          familyName:@”test-family”
                                                                                                     email:nil
                                                                             channelInformations:@{@"url":self.propertyUrl}
                                                                                          deviceToken:nil
                                                                                completionHandler:nil];
 [self.navigationController pushViewController:chatViewController animated:YES];

…
```

**認証エラーが発生した場合の挙動について**
認証エラーが発生した場合は、認証エラーダイアログが表示されます。ユーザーが認証エラーダイアログを閉じるタイミングでChat画面も同時に閉じたい場合は、ChatCenterDelegateの実装をお願いします。

#### 3. History Viewの呼び出し
チャット履歴を表示するHistory viewを呼び出します。  
<img src="https://github.com/chatcenter/ios/blob/master/Images/historyview.png" width="375" height="667">

##### 3-1. 認証ありの場合
以下のコードを任意の場所に挿入してください。

```
- (id)getHistoryView::(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
   completionHandler:(void (^)(void))completionHandler;
```

###### (a)Facebook認証でのパラメータ
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **provider:(NSString *): @”facebook”を指定してください**
* **providerToken:(NSString *): 認証結果のtokenを指定してください**
* providerTokenSecret:(NSString *): nilを指定してください
* providerCreatedAt:(NSDate *): nilを指定してください
* **providerExpiresAt:(NSDate *): 認証結果のtokenの失効日(expirationDate)を指定してください**
* completionHandler:(void (^)(void)): ヒストリー画面を閉じる際に呼ぶコールバック処理を指定してください(画面上部の戻るボタンをカスタマイズした場合にのみ適用されます。カスタマイズについては、デザインのカスタマイズをご覧ください)

```例
#import "ChatCenter.h"

…

      UIViewController *historyViewController = [[ChatCenter sharedInstance] getHistoryView:@"facebook"
      											                                   providerToken:token.tokenString 
                                                                        providerTokenSecret:nil
                                                                          providerCreatedAt:nil 
                                                                          providerExpiresAt:token.expirationDate
                                                                          completionHandler:nil];
                                                                        
    [self.navigationController pushViewController:historyViewController animated:YES];

…
```

###### (b)Twitter認証でのパラメータ
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **provider:(NSString *): @"twitter"を指定してください**
* **providerToken:(NSString *): 認証結果のauthTokenを指定してください**
* **providerTokenSecret:(NSString *):Access token secretを指定してください**
* providerCreatedAt:(NSDate *): nilを指定してください
* providerExpiresAt:(NSDate *): nilを指定してください
* completionHandler:(void (^)(void)): ヒストリー画面を閉じる際に呼ぶコールバック処理を指定してください(画面上部の戻るボタンをカスタマイズした場合にのみ適用されます。カスタマイズについては、デザインのカスタマイズをご覧ください)

```例
#import "ChatCenter.h"

…

     UIViewController *historyViewController = [[ChatCenter sharedInstance] getHistoryView:@"twitter"
                                                                             providerToken:session.authToken
                                                                       providerTokenSecret:session.authTokenSecret
                                                                         providerCreatedAt:nil
                                                                         providerExpiresAt:nil
                                                                         completionHandler:nil];
                                                                       
   [self.navigationController pushViewController:historyViewController animated:YES];

…
```

##### 3-2. 認証なしの場合(Anonymousログイン)
**注意: 認証なしのユーザーに対して、後から認証処理を紐付けることは現在対応しておりません**
以下のコードを任意の場所に挿入してください。

``- (id)getHistoryView:(void (^)(void))completionHandler;``

##### パラメータ
必須ではありません。不要な場合はnilをご指定ください。

* completionHandler:(void (^)(void)): ヒストリー画面を閉じる際に呼ぶコールバック処理を指定してください(画面上部の戻るボタンをカスタマイズした場合にのみ適用されます。カスタマイズについては、デザインのカスタマイズをご覧ください)

```例
#import "ChatCenter.h"

…

    UIViewController *historyViewController = [[ChatCenter sharedInstance] getHistoryView:nil];
      
    [self.navigationController pushViewController:historyViewController animated:YES];



…
```

※ 認証エラーが発生した場合の挙動について
認証エラーが発生した場合は、認証エラーダイアログが表示されます。ユーザーが認証エラーダイアログを閉じるタイミングでChat画面も同時に閉じたい場合は、17-1. 認証エラーダイアログを閉じるタイミングを取得する場合を参照し、実装をお願いします。

#### 4. ユーザーのログアウト
ChatCenter iOS SDKではチャットデータをローカルDB(Coredata)へ保存しており、ユーザーのログアウト時には以下をコールしてデータのリセットをお願いします。
``- (BOOL)signOut;``

#### 5. プッシュ通知
**※ プッシュ通知を実施される場合は、p12ファイル及びパスワードを弊社の担当者へ送付ください。**
##### 5-1. プッシュ通知のオン
###### (a)Chat Viewを表示時に行う
Chat Viewの呼び出しの際に、Appleより取得したデバイストークンをdeviceTokenに設定してください。登録の時点でプッシュ通知は有効になります。
###### (b)任意のタイミングで行う
  サインイン等、プッシュ通知を有効にしたいタイミングで以下をコールしてください。ChatCenterの画面を呼び出す前にプッシュ通知をオンにしたい場合に使用してください。

```
- (void)signInDeviceToken:(NSString*)email
                 password:(NSString*)password
                 provider:(NSString *)provider
            providerToken:(NSString *)providerToken
providerTokenSecret:(NSString *)providerTokenSecret 
        providerCreatedAt:(NSDate *)providerCreatedAt
        providerExpiresAt:(NSDate *)providerExpiresAt
              deviceToken:(NSString *)deviceToken
        completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
```

**Facebook認証でのパラメータ**
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* email:(NSString *): nilを指定してください
* password:(NSString*): nilを指定してください
* **provider:(NSString *): @”facebook”を指定してください**
* **providerToken:(NSString *): 認証結果のtokenを指定してください**
* providerTokenSecret:(NSString *): nilを指定してください
* providerCreatedAt:(NSDate *): nilを指定してください
* **providerExpiresAt:(NSDate *): 認証結果のtokenの失効日(expirationDate)を指定してください**
* **deviceToken:(NSString *): プッシュ通知で使用するAppleから取得したdeviceTokenを指定してください**
* completionHandler:(void (^)(NSDictionary *result, NSError *error)): 通信後のコールバック処理を指定してください。通信結果が含まれます

**Twitter認証でのパラメータ**
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* email:(NSString *): nilを指定してください
* password:(NSString*): nilを指定してください
* **provider:(NSString *): @"twitter"を指定してください**
* **providerToken:(NSString *): 認証結果のauthTokenを指定してください**
* **providerTokenSecret:(NSString *):Access token secretを指定してください**
* providerCreatedAt:(NSDate *): nilを指定してください
* providerExpiresAt:(NSDate *): nilを指定してください
* **deviceToken:(NSString *): プッシュ通知で使用するAppleから取得したdeviceTokenを指定してください**
* completionHandler:(void (^)(NSDictionary *result, NSError *error)): 通信後のコールバック処理を指定してください。通信結果が含まれます

##### 5-2. プッシュ通知のオフ
サインアウト等、プッシュ通知を無効にしたいタイミングで以下をコールしてください。

```
- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
```

**パラメータ**
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **deviceToken:(NSString *): プッシュ通知で使用するAppleから取得したdeviceTokenを指定してください**
* completionHandler:(void (^)(NSDictionary *result, NSError *error)): 通信後のコールバック処理を指定してください。通信結果が含まれます


##### 5-3. プッシュ通知の受信
受信時のペイロードからorg_uidを取り出し、Chat Viewの呼び出しを行ってください。
以下のようなペイロードが送信されます。

```
{
 "aps": {
   "alert": "app_name チャットセンターでメッセージを受信しました。",
   "badge": unread_count,
   "sound": "default",
   "category": "chat message",
   "content-available": 1
 },
 "data": {
   "org_uid": org_uid,
   "channel_uid": channel_uid,
 }
}
```

**変数**

* app_name -> アプリ名
* unread_count -> 未読のチャネル数
* org_uid -> Organization Uid(法人/店舗ID)
* channel_uid -> チャネルUID

### オプション(API)

#### 1. デザインのカスタマイズ
setAppTokenのcompletionHandler内でセットをしてください

##### 1-1. Base color  
``+ (void)setBaseColor:(UIColor *)baseColor;``  
ベースカラーを設定できます。以下に適応されます

* (チャットビュー) 自分が送信したチャットバブルの背景色
* (チャットビュー) ステッカーメニューアイコンの色
* (チャットビュー) ステッカーメニューの色

##### 1-2. Image preview close button image
``+ (void)setCloseBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;``
チャット画面内で開く画像プレビューの閉じるボタンを設定します。

##### 1-3. Back button image
``+ (void)setBackBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;``
チャットビューおよびヒストリービューの戻るボタンを設定します。

##### 1-4. Phone call button image
``+ (void)setPhoneBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;``
チャットビューのエージェンへ電話するボタンを設定します。

##### 1-5. Send button color
``+ (void)setSendButtonColor:(UIColor *)sendButtonColor;``
チャットビューの送信ボタンの色を設定します。

##### 1-6. History view title
``+ (void)setHistoryViewTitle:(NSString *)historyViewTitle;``
ヒストリービューのタイトルの文言を設定します

##### 1-7. History view void message
``+ (void)setHistoryViewVoidMessage:(NSString *)historyViewVoidMessage;``
ヒストリービューでチャットが0件の場合に表示する文言を設定します

```例
#import "ChatCenter.h"

…

- (void)viewDidLoad {
    [super viewDidLoad];
    [ChatCenter setAppToken:APP_TOKEN completionHandler:^{
        [ChatCenter setBaseColor:[UIColor colorWithRed:111.0/255.0 green:186.0/255.0 blue:44.0/255.0 alpha:1.0]];
        [ChatCenter setSendButtonColor:[UIColor colorWithRed:111.0/255.0 green:186.0/255.0 blue:44.0/255.0 alpha:1.0]];
        [ChatCenter setHistoryViewTitle:@"メッセージ"];
        [ChatCenter setHistoryViewVoidMessage:@"チャットがありません。"];
        [ChatCenter setBackBtnImage:@"CCback-icon.png" hilighted:@"CCback-icon_pressed.png" disable:@"CCback-icon_disable.png"];
        [ChatCenter setCloseBtnImage:@"CCclose-icon.png" hilighted:@"CCclose-icon_pressed.png" disable:@"CCclose-icon_disable.png"];
        [ChatCenter setPhoneBtnImage:@"DemoPhone-icon.png" hilighted:@"DemoPhone-icon_pressed.png" disable:nil];
    }];

…
```

#### 2. 認証済みユーザーかの確認
以下のコードを任意の場所に挿入してください。
``- (BOOL)hasChatUser;``

**パラメータ**
なし

```例
#import "ChatCenter.h"

…

if([[ChatCenter sharedInstance] hasChatUser] == YES){
   ///認証済ユーザー
}else{
   ///未認証ユーザー
}

…
```

#### 3. 指定のOrganizationでチャット開始済みユーザーかの確認
以下のコードを任意の場所に挿入してください。
``- (BOOL)hasChannel:(NSString *)orgUid;``

**パラメータ**
必須のパラメータになります。

* orgUid:(NSString *): Chatに紐づく、Organization uidを指定してください

```例
#import "ChatCenter.h"

…

if([[ChatCenter sharedInstance] hasChannel:@”organization_id”] == YES){
   ///チャット開始済ユーザー
}else{
   ///チャットを開始していないユーザー
}

…
```

#### 4. 未読メッセージの有無
以下のコードを任意の場所に挿入してください。
``- (BOOL)isUnreadMessageCount;``

**パラメータ**
なし

```例
#import "ChatCenter.h"

…

if([[ChatCenter sharedInstance] isUnreadMessageCount] == YES){
   ///未読メッセージあり
}else{
   ///未読メッセージなし
}

…
```



#### 5. Anonymousログインで事前にチャットデータをロードする場合
以下のコードをsetAppTokenが完了後に挿入してください。(setAppTokenのcompletionHandler内に指定いただくことを推奨します)

``- (void)signInWithAnonymous;``

```例
#import "ChatCenter.h"

…

- (void)viewDidLoad {
    [super viewDidLoad];
    [ChatCenter setAppToken:APP_TOKEN completionHandler:^{
        …..    
        …..

        [[ChatCenter sharedInstance] signInWithAnonymous];
    }];

}
…
```

#### 6. Orgのオンライン/オフラインを取得する
以下のコードを任意の場所に挿入してください。

``- (void)isOrgOnline:orgUid completeHandler:(void (^)(BOOL isOnline))completionHandler;``

**パラメータ**
太字が必須のパラメータになります。他のパラメータで不要な場合はnilをご指定ください。

* **orgUid:(NSString *): オンライン/オフラインを取得したいOrganization uidを指定してください**
* completeHandler:(void (^)(BOOL isOnline))completionHandler: 通信後のコールバック処理を指定してください。通信結果が含まれます。

※該当Orgに所属するエージェントが1名以上オンラインだった場合にcompletionHandlerのisOnlineにYESが返却されます。それ以外はNOが返却されます。

```例
#import "ChatCenter.h"

…

[[ChatCenter sharedInstance] isOrgOnline:orgUid completeHandler:^(BOOL isOnline) {
        if (isOnline) {
            ///Org online
        }else{
            ///Org offline
        }
    }];

…
```

#### 7. ChatCenterDelegate
ChatCenter内のイベントを検知していただく手段として、ChatCenterDelegate prptocolを用意しております。必要に応じて実装ください。

**ChatCenterDelegate protocol**

```
@protocol ChatCenterDelegate <NSObject>
@required
なし
@optional
- (void)authenticationErrorAlertClosed;
```

#### 8. 認証エラーダイアログを閉じるタイミングを取得する場合
認証エラー時に表示されるダイアログをユーザーが閉じるイベントを検知できます。
ChatCenterDelegateの以下のメソッドを任意の場所に挿入してください。
``- (void)authenticationErrorAlertClosed;``

```例
#import "ChatCenterDelegate.h"

@interface SampleViewController : UIViewController<ChatCenterDelegate>
…
@end

…
@implementation SampleViewController
…. 
- (void)authenticationErrorAlertClosed{
    NSLog(@"authenticationErrorAlertClosed is called");
    [self.navigationController popViewControllerAnimated:YES];
}
…
```
