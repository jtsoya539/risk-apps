﻿using Risk.Maui.Services.Dialog;
using Risk.Maui.Services.Navigation;
using Risk.Maui.Services.Settings;

namespace Risk.Maui.ViewModels.Base;

public abstract partial class ViewModelBase : ObservableObject, IViewModelBase
{
    private long _isBusy;

    public bool IsBusy => Interlocked.Read(ref _isBusy) > 0;

    [ObservableProperty]
    private bool _isInitialized;

    public ISettingsService SettingsService { get; }

    public INavigationService NavigationService { get; }

    public IDialogService DialogService { get; }

    public IAsyncRelayCommand InitializeAsyncCommand { get; }

    public ViewModelBase(ISettingsService settingsService, INavigationService navigationService, IDialogService dialogService)
    {
        SettingsService = settingsService;
        NavigationService = navigationService;
        DialogService = dialogService;

        InitializeAsyncCommand =
            new AsyncRelayCommand(
                async () =>
                {
                    await IsBusyFor(InitializeAsync);
                    IsInitialized = true;
                },
                AsyncRelayCommandOptions.FlowExceptionsToTaskScheduler);
    }

    public virtual void ApplyQueryAttributes(IDictionary<string, object> query)
    {
    }

    public virtual Task InitializeAsync()
    {
        return Task.CompletedTask;
    }

    public async Task IsBusyFor(Func<Task> unitOfWork)
    {
        Interlocked.Increment(ref _isBusy);
        OnPropertyChanged(nameof(IsBusy));

        var pop = await DialogService.ShowLoadingAsync("Cargando");

        try
        {
            await unitOfWork();
        }
        finally
        {
            Interlocked.Decrement(ref _isBusy);
            OnPropertyChanged(nameof(IsBusy));

            pop.Close();
        }
    }
}
