using System.Resources;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]
[assembly: ExportFont("fa-brands-400.ttf", Alias = "FontAwesomeBrands")]
[assembly: ExportFont("fa-regular-400.ttf", Alias = "FontAwesomeRegular")]
[assembly: ExportFont("fa-solid-900.ttf", Alias = "FontAwesomeSolid")]

// The resources from the neutral language .resx file are stored directly
// within the library assembly. For that reason, changing en-US to a different
// language in this line will not by itself change the language shown in the
// app. See the discussion of UltimateResourceFallbackLocation in the
// documentation for additional information:
// https://docs.microsoft.com/dotnet/api/system.resources.neutralresourceslanguageattribute
[assembly: NeutralResourcesLanguage("es")]
