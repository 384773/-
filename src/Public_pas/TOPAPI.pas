unit TOPAPI;

interface
uses
  Alimama_Const,
  IdHTTP, IdHashMessageDigest, System.Classes, IdGlobal, System.NetEncoding,
  System.JSON, System.SysUtils;

  function IDHTTP_Get(var sParams:TStringList): TJSONObject;
  function taobao_tbk_item_coupon_get(const pid:string): Boolean;


implementation

function  URLEncode(const S:String; const InQueryString: Boolean): string;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := 1 to Length(S) do
  begin
      case S[Idx] of
        'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.', '=', '&', '%', '/':
          Result := Result + S[Idx];
        ' ':
          if InQueryString then
            Result := Result + '+'
          else
            Result := Result + '%20';
        ',':
           Result :=Result + '%2C';
        ':':
           Result := Result + '%3A';
      else
          Result := Result + TNetEncoding.URL.Encode(string(UTF8Encode(s[Idx])));

      end;
  end;
end;

function IDHTTP_Get(var sParams:TStringList): TJSONObject;
var
  tmpidHttp : TIdHTTP;
  i : Integer;
  tmpMD5String, tmpMD5sign, AHttpRequestURL : string;
  AHttpReponseContent : TMemoryStream;
begin
  tmpidHttp := TIdHTTP.Create(nil);
  AHttpReponseContent := TMemoryStream.Create;
  try
    //idhttp配置
    tmpidHttp.ReadTimeout:=0;
    tmpidHttp.AllowCookies:=True;
    tmpidHttp.ProxyParams.BasicAuthentication:=False;
    tmpidHttp.ProxyParams.ProxyPort:=0;
    tmpidHttp.Request.ContentLength:=-1;
    tmpidHttp.Request.ContentRangeEnd:=0;
    tmpidHttp.Request.ContentRangeStart:=0;
    tmpidHttp.Request.ContentType:='application/x-www-form-urlencoded';
    tmpidHttp.Request.Accept:='text/html, */*';
    tmpidHttp.Request.BasicAuthentication:=False;
    tmpidHttp.Request.UserAgent:='Mozilla/3.0 (compatible; Indy Library)';
    tmpidHttp.HTTPOptions:=[hoForceEncodeParams];

    //排序
    sParams.Sort;
    tmpMD5String := '';
    //拼接参数名与参数值
    for I := 0 to sParams.Count - 1 do
      begin
        if sParams.Names[i] <> '' then
          begin
            tmpMD5String := tmpMD5String + sParams.Names[i];
            tmpMD5String := tmpMD5String + sParams.ValueFromIndex[i];
          end
        else
          begin
            Exit;
          end;
      end;
    tmpMD5String := Const_AppSecret + tmpMD5String;

    //生成签名
    tmpMD5sign := Var_MD5.HashStringAsHex(tmpMD5String, IndyTextEncoding_UTF8);
    sParams.Add('sign=' + tmpMD5sign);

    //拼装请求地址
    for I := 0 to sParams.Count - 1 do
      begin
        if sParams.Names[i] <> '' then
          begin
            AHttpRequestURL := AHttpRequestURL +'&' + sParams[i];
          end
        else
          begin
            Exit;
          end;
      end;

    //url编码，加上请求地址
    AHttpRequestURL := URLEncode(AHttpRequestURL, True);;
    AHttpRequestURL := Const_RequestUrl + AHttpRequestURL;

    //发送请求并接受返回
    tmpidHttp.Get(AHttpRequestURL,AHttpReponseContent);
    AHttpReponseContent.Position:=0;
    Result := TJSONObject.ParseJSONValue(AHttpReponseContent.ToString) as TJSONObject;

  finally
    AHttpReponseContent.Free;
    tmpidHttp.Free;
  end;
end;

function taobao_tbk_item_coupon_get(const pid:string): Boolean;
var
  tmpParams : TStringList;
  getJson : TJSONObject;
begin
  tmpParams := TStringList.Create;
  tmpParams.Assign(Var_Params);
  tmpParams.Add('timestamp='+FormatDateTime('yyyy-mm-dd hh:mm:ss',now));

  //业务参数配置
  tmpParams.Add('pid=' + pid);

  //发送请求，返回json
  getJson := IDHTTP_Get(tmpParams);


end;

end.
