using System;
using System.Diagnostics;

namespace sourcesharp.app.legion;

internal class LegionApp : BaseApp
{
    // Одиночка (Singleton) без макросов и extern
    private static readonly LegionApp _instance = new();
    public static LegionApp Instance => _instance;

    public override bool Create()
    {
        // Кастомный перенаправитель вывода логов движка (Вместо SpewFunc)
        Trace.Listeners.Add(new ConsoleTraceListener());
        
        // Инициализация математического ядра
        MathLib.Init(2.2f, 2.2f, 0.0f, 2.0f, false);

        return base.Create();
    }

    public override bool PreInit()
    {
        if (!base.PreInit()) return false;

        // Проверяем только то, что реально критично для старта C# движка
        if (InputSystem.Instance == null || FileSystem.Instance == null || RenderSystem.Instance == null)
        {
            Trace.WriteLine("LegionApp: Ошибка! Критические подсистемы не инициализированы.");
            return false;
        }

        return true;
    }

    public override void PostShutdown()
    {
        base.PostShutdown();
    }

    // Главная точка входа в жизненный цикл игрового приложения
    public int MainLoop()
    {
        if (!SetVideoMode()) 
            return 0;

        // Регистрируем подсистемы в Game Manager (Порядок важен для кадров)
        // Больше никаких глобальных g_p указателей
        GameManager.Add(WorldManager.Instance);   // База данных мира
        GameManager.Add(RenderManager.Instance);  // Отрендерить кадр (DX12)
        GameManager.Add(NetworkManager.Instance); // Сетевой трафик
        GameManager.Add(InputManager.Instance);   // Ввод пользователя
        GameManager.Add(MenuManager.Instance);    // Контроль меню (UI)
        GameManager.Add(UIManager.Instance);      // Игровой интерфейс
        GameManager.Add(PhysicsManager.Instance); // Физический движок / Симуляция

        // Инициализируем все добавленные менеджеры
        if (!GameManager.InitAllManagers()) 
            return 0;

        // Загружаем стартовое меню приложения
        MenuManager.Instance.PushMenu("MainMenu");

        // Главный игровой цикл (блокирующий вызов)
        GameManager.Start();

        // Очистка при выходе из игры
        GameManager.ShutdownAllManagers();

        return 1;
    }
}

// --- Базовые заглушки архитектуры для сборки в VS Code Insiders ---
internal class BaseApp 
{ 
    public virtual bool Create() => true; 
    public virtual bool PreInit() => true; 
    public virtual void PostShutdown() {} 
    protected bool SetVideoMode() => true; 
}

internal static class MathLib { public static void Init(float a, float b, float c, float d, bool f) {} }
internal class InputSystem { public static InputSystem Instance { get; } = new(); }
internal class FileSystem { public static FileSystem Instance { get; } = new(); }
internal class RenderSystem { public static RenderSystem Instance { get; } = new(); }

// Системные синглтоны менеджеров
internal class WorldManager : IGameSystem { public static WorldManager Instance { get; } = new(); }
internal class RenderManager : IGameSystem { public static RenderManager Instance { get; } = new(); }
internal class NetworkManager : IGameSystem { public static NetworkManager Instance { get; } = new(); }
internal class MenuManager : IGameSystem { public static MenuManager Instance { get; } = new(); public void PushMenu(string name) {} }
internal class UIManager : IGameSystem { public static UIManager Instance { get; } = new(); }
internal class PhysicsManager : IGameSystem { public static PhysicsManager Instance { get; } = new(); }

internal interface IGameSystem {}
internal static class GameManager
{
    public static void Add(IGameSystem system) {}
    public static bool InitAllManagers() => true;
    public static void Start() {}
    public static void ShutdownAllManagers() {}
}
