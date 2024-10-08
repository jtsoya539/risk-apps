﻿using Risk.Maui.Services.Settings;

namespace Risk.Maui.Services.Navigation
{
    public class MauiNavigationService : INavigationService
    {
        private readonly ISettingsService _settingsService;

        public MauiNavigationService(ISettingsService settingsService)
        {
            _settingsService = settingsService;
        }

        public Task InitializeAsync() =>
            NavigateToAsync(string.IsNullOrEmpty(_settingsService.AccessToken)
                ? $"//{Routes.LoginPage}"
                : $"//{Routes.MainPage}");

        public Task NavigateToAsync(string route, IDictionary<string, object> routeParameters = null)
        {
            var shellNavigation = new ShellNavigationState(route);

            return routeParameters != null
                ? Shell.Current.GoToAsync(shellNavigation, routeParameters)
                : Shell.Current.GoToAsync(shellNavigation);
        }

        public Task PopAsync() =>
            Shell.Current.GoToAsync("..");
    }
}

