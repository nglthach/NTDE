{

  MIT License

  Copyright (c) 2017 nglthach

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

}

unit NTDE.AdMob.InterstitialAds;

interface

uses

{$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.AdMob,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Media,
  Androidapi.JNI.PlayServices,
  Androidapi.JNIBridge,
  FMX.Helpers.Android,
  FMX.Media.Android,
  FMX.Platform.Android,
{$ENDIF}
  FMX.Advertising,
  FMX.Types,
  FMX.Objects,
  System.Classes;

type

  TNTDEAdMobInterstitialAd = class;

{$IFDEF ANDROID}
  TInterstitialAdViewListener = class(TJavaLocal, JIAdListener)
  private
    FInterstitialAd: TNTDEAdMobInterstitialAd;
  public
    constructor Create(AInterstitialAd: TNTDEAdMobInterstitialAd);
    procedure onAdClosed; cdecl;
    procedure onAdFailedToLoad(errorCode: Integer); cdecl;
    procedure onAdLeftApplication; cdecl;
    procedure onAdOpened; cdecl;
    procedure onAdLoaded; cdecl;
  end;
{$ENDIF}

  TOnAdFailedToLoad = procedure (Sender: TObject; ErrorCode: Integer) of object;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidAndroid)]
  TNTDEAdMobInterstitialAd = class(TComponent)
  private
    FOnAdClosed: TNotifyEvent;
    FOnAdFailedToLoad: TOnAdFailedToLoad;
    FOnAdLeftApplication:TNotifyEvent;
    FOnAdOpened: TNotifyEvent;
    FOnAdLoaded: TNotifyEvent;
    FAdUnitId: string;
    FTestMode: Boolean;
  {$IFDEF ANDROID}
    FAdViewListener: TInterstitialAdViewListener;
    FInterstitialAd: JInterstitialAd;
  {$ENDIF}
    procedure SetAdUnitId(const AAdUnitId: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadAd;
    procedure ShowAd;
  published
    property AdUnitId: string read FAdUnitId write SetAdUnitId;
    property TestMode: Boolean read FTestMode write FTestMode;
    property OnAdClosed: TNotifyEvent read FOnAdClosed write FOnAdClosed;
    property OnAdFailedToLoad: TOnAdFailedToLoad read FOnAdFailedToLoad write FOnAdFailedToLoad;
    property OnAdLeftApplication:TNotifyEvent read FOnAdLeftApplication write FOnAdLeftApplication;
    property OnAdOpened: TNotifyEvent read FOnAdOpened write FOnAdOpened;
    property OnAdLoaded: TNotifyEvent read FOnAdLoaded write FOnAdLoaded;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('NTDE', [TNTDEAdMobInterstitialAd]);
end;

{$IFDEF ANDROID}

{ TInterstitialAdViewListener }

constructor TInterstitialAdViewListener.Create(AInterstitialAd: TNTDEAdMobInterstitialAd);
begin
  inherited Create;

  FInterstitialAd := AInterstitialAd;
end;

procedure TInterstitialAdViewListener.onAdClosed;
begin
  if Assigned(FInterstitialAd.OnAdClosed) then
    FInterstitialAd.OnAdClosed(FInterstitialAd);
end;

procedure TInterstitialAdViewListener.onAdFailedToLoad(errorCode: Integer);
begin
  if Assigned(FInterstitialAd.OnAdFailedToLoad) then
    FInterstitialAd.OnAdFailedToLoad(FInterstitialAd, errorCode);
end;

procedure TInterstitialAdViewListener.onAdLeftApplication;
begin
  if Assigned(FInterstitialAd.OnAdLeftApplication) then
    FInterstitialAd.OnAdLeftApplication(FInterstitialAd);
end;

procedure TInterstitialAdViewListener.onAdLoaded;
begin
  if Assigned(FInterstitialAd.OnAdLoaded) then
    FInterstitialAd.OnAdLoaded(FInterstitialAd);
end;

procedure TInterstitialAdViewListener.onAdOpened;
begin
  if Assigned(FInterstitialAd.OnAdOpened) then
    FInterstitialAd.OnAdOpened(FInterstitialAd);
end;

{$ENDIF}

{ TInterstitialAd }

constructor TNTDEAdMobInterstitialAd.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF ANDROID}
  FInterstitialAd := TJInterstitialAd.JavaClass.init(MainActivity);
  {$ENDIF}
end;

procedure TNTDEAdMobInterstitialAd.LoadAd;
{$IFDEF ANDROID}
var
  LAdRequestBuilder: JAdRequest_Builder;
  LAdRequest: JAdRequest;
{$ENDIF}
begin
{$IFDEF ANDROID}
  LAdRequestBuilder := TJAdRequest_Builder.Create;

  if FTestMode then
    LAdRequestBuilder.addTestDevice(MainActivity.getDeviceID);

  LAdRequest := LAdRequestBuilder.build();
  FAdViewListener := TInterstitialAdViewListener.Create(Self);
  CallInUIThread(
    procedure
    begin
      FInterstitialAd.setAdListener(TJAdListenerAdapter.JavaClass.init
        (FAdViewListener));
      FInterstitialAd.loadAd(LAdRequest);
    end
  );
{$ENDIF}
end;

procedure TNTDEAdMobInterstitialAd.SetAdUnitId(const AAdUnitId: string);
begin
  if FAdUnitId <> AAdUnitId then
  begin
    FAdUnitId := AAdUnitId;
    {$IFDEF ANDROID}
    FInterstitialAd.setAdUnitId(StringToJString(FAdUnitId));
    {$ENDIF}
  end;
end;

procedure TNTDEAdMobInterstitialAd.ShowAd;
begin
{$IFDEF ANDROID}
  FInterstitialAd.show;
{$ENDIF}
end;

end.
