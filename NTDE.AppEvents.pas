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


unit NTDE.AppEvents;

interface

uses
  {$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Media,
  Androidapi.JNI.PlayServices,
  Androidapi.JNI.Os,
  Androidapi.JNIBridge,
  FMX.Helpers.Android,
  FMX.Media.Android,
  FMX.Platform.Android,
  {$ENDIF}
  FMX.Types,
  FMX.Platform,
  System.Classes;

type

  TNTDEAppEvents = class;
  {$IFDEF ANDROID}
  TBroadcastReceiverListener = class(TJavaLocal, JFMXBroadcastReceiverListener)
    private
      FOwner: TNTDEAppEvents;
    public
      constructor Create(AOwner: TNTDEAppEvents);
      procedure onReceive(context: JContext; intent: JIntent); cdecl;
  end;
  {$ENDIF}

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidiOSDevice32 or pidiOSDevice64 or pidiOSSimulator or pidAndroid)]
  TNTDEAppEvents = class(TComponent)
  private
    FFMXApplicationEventService: IFMXApplicationEventService;
    {$IFDEF ANDROID}
    FBroadcastReceiver: JBroadcastReceiver;
    FBroadcastReceiverListener: TBroadcastReceiverListener;
    {$ENDIF}
  private
    FOnAppFinishedLaunching: TNotifyEvent;
    FOnAppBecameActive: TNotifyEvent;
    FOnAppEnteredBackground: TNotifyEvent;
    FOnAppWillBecomeForeground: TNotifyEvent;
    FOnAppWillTerminate: TNotifyEvent;
    FOnLowMemory: TNotifyEvent;
    FOnScreenOn: TNotifyEvent;
    FOnScreenOff: TNotifyEvent;
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    procedure DoScreenOn;
    procedure DoScreenOff;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeforeDestruction; override;
  published
    property OnAppFinishedLaunching: TNotifyEvent read FOnAppFinishedLaunching write FOnAppFinishedLaunching;
    property OnAppBecameActive: TNotifyEvent read FOnAppBecameActive write FOnAppBecameActive;
    property OnAppEnteredBackground: TNotifyEvent read FOnAppEnteredBackground write FOnAppEnteredBackground;
    property OnAppWillBecomeForeground: TNotifyEvent read FOnAppWillBecomeForeground write FOnAppWillBecomeForeground;
    property OnAppWillTerminate: TNotifyEvent read FOnAppWillTerminate write FOnAppWillTerminate;
    property OnLowMemory: TNotifyEvent read FOnLowMemory write FOnLowMemory;
    property OnScreenOn: TNotifyEvent read FOnScreenOn write FOnScreenOn;
    property OnScreenOff: TNotifyEvent read FOnScreenOff write FOnScreenOff;
  end;

procedure Register;

implementation

uses System.SysUtils;

procedure Register;
begin
  RegisterComponents('NTDE', [TNTDEAppEvents]);
end;

procedure TNTDEAppEvents.BeforeDestruction;
begin
  inherited;
  {$IFDEF ANDROID}
  TAndroidHelper.Context.unregisterReceiver(FBroadcastReceiver);
  {$ENDIF}
end;

constructor TNTDEAppEvents.Create(AOwner: TComponent);
{$IFDEF ANDROID}
var
  LIntentFilter: JIntentFilter;
{$ENDIF}
begin
  inherited;

  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(FFMXApplicationEventService)) then
    FFMXApplicationEventService.SetApplicationEventHandler(HandleAppEvent);

  {$IFDEF ANDROID}
  LIntentFilter := TJIntentFilter.Create;
  LIntentFilter.addAction(TJIntent.JavaClass.ACTION_SCREEN_ON);
  LIntentFilter.addAction(TJIntent.JavaClass.ACTION_SCREEN_OFF);

  FBroadcastReceiverListener := TBroadcastReceiverListener.Create(Self);
  FBroadcastReceiver := TJFMXBroadcastReceiver.JavaClass.init(FBroadcastReceiverListener);
  TAndroidHelper.Context.registerReceiver(FBroadcastReceiver, LIntentFilter);
  {$ENDIF}
end;

function TNTDEAppEvents.HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  case AAppEvent of
    TApplicationEvent.FinishedLaunching:    if Assigned(FOnAppFinishedLaunching) then FOnAppFinishedLaunching(Self);
    TApplicationEvent.BecameActive:         if Assigned(FOnAppBecameActive) then FOnAppBecameActive(Self);
    TApplicationEvent.EnteredBackground:    if Assigned(FOnAppEnteredBackground) then FOnAppEnteredBackground(Self);
    TApplicationEvent.WillBecomeForeground: if Assigned(FOnAppWillBecomeForeground) then FOnAppWillBecomeForeground(Self);
    TApplicationEvent.WillBecomeInactive:   if Assigned(FOnAppFinishedLaunching) then FOnAppFinishedLaunching(Self);
    TApplicationEvent.WillTerminate:        if Assigned(FOnAppWillTerminate) then FOnAppWillTerminate(Self);
    TApplicationEvent.LowMemory:            if Assigned(FOnLowMemory) then FOnLowMemory(Self);
  end;
  Result := True;
end;

procedure TNTDEAppEvents.DoScreenOff;
begin
  if Assigned(FOnScreenOff) then
    FOnScreenOff(Self);
end;

procedure TNTDEAppEvents.DoScreenOn;
begin
  if Assigned(FOnScreenOn) then
    FOnScreenOn(Self);
end;

{$IFDEF ANDROID}

constructor TBroadcastReceiverListener.Create(AOwner: TNTDEAppEvents);
begin
  inherited Create;

  FOwner := AOwner;
end;

procedure TBroadcastReceiverListener.onReceive(context: JContext; intent: JIntent);
begin
  if Assigned(FOwner) then
  begin
    if intent.getAction.equals(TJIntent.JavaClass.ACTION_SCREEN_ON) then
      FOwner.DoScreenOn
    else if intent.getAction.equals(TJIntent.JavaClass.ACTION_SCREEN_OFF) then
      FOwner.DoScreenOff;
  end;
end;

{$ENDIF}

end.
