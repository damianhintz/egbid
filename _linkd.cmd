@if not exist lib mkdir lib
@rem Utworzenie polaczenia do biblioteki (linkd from Windows Resource Kits)
@d:\projekty\biblioteki\bin\linkd.exe .\lib d:\projekty\biblioteki\mdl
@pause