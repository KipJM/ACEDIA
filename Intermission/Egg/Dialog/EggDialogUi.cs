using System;
using System.Collections.Generic;
using Godot;
using MEC;

namespace Pins.Intermission.Egg.Dialog;

public partial class EggDialogUi : Control
{
    [ExportGroup("Controls")]
    [Export] public RichTextLabel TextLabel;
    [Export] public Control TextShadow;
    [Export] public Control InputHint;
    [Export] public AudioStreamPlayer TonePlayer;
    [ExportGroup("Animation")] 
    [Export] public AnimationTree Animator;
    [Export] public AnimationTree SkyAnimator;
    [ExportGroup("Configs")] 
    [Export] public float ShadowInDuration;
    [Export] public float HintInDuration;
    
    private DialogEntry _currentEntry;

    private bool _acceptInput = false;

    private AnimationNodeStateMachinePlayback _playback;
    private AnimationNodeStateMachinePlayback _skyPlayback;
    
    [Signal]
    public delegate void EntryFinishedEventHandler();
    
    public override void _Ready()
    {
        base._Ready();
        Hide();
        _playback = (AnimationNodeStateMachinePlayback)Animator.Get("parameters/playback");
        _skyPlayback = (AnimationNodeStateMachinePlayback)SkyAnimator.Get("parameters/playback");
    }

    public void ShowUi()
    {
        Show();
        // Hide text and hint
        TextLabel.Hide();
        InputHint.Hide();
    }

    public void StartEntry(DialogEntry entry)
    {
        _acceptInput = false;
        _currentEntry = entry;

        // Animation
        switch (_currentEntry.HaveAnimation)
        {
            case DialogAnimType.None:
                break;
            case DialogAnimType.Local:
                _playback.Travel(_currentEntry.TargetAnimationKey);
                break;
            case DialogAnimType.Sky:
                _skyPlayback.Travel(_currentEntry.TargetAnimationKey);
                break;
        }
        
        if (entry.InWaitDuration > 0)
        {
            Timing.RunCoroutine(Wait(entry.InWaitDuration, EntryIn));
        }
        else
        {
            // Immediate
            EntryIn();
        }

    }

    void EntryIn() {
        // Set text
        TextLabel.Text = _currentEntry.Content;
        
        // Fade in text
        TextLabel.Show();
        TextLabel.Modulate = TextLabel.Modulate with { A = 1 };
        TextShadow.Modulate = TextShadow.Modulate with { A = 1 };
        
        if (_currentEntry.InDuration > 0)
        {
            switch (_currentEntry.InType)
            {
                case DialogTransType.Typewriter:
                    Timing.RunCoroutine(TypeText(_currentEntry.InDuration, 0, 1, TextFadeInFinished));
                    break;
                case DialogTransType.Fade:
                    Timing.RunCoroutine(FadeText(_currentEntry.InDuration, 0, 1, TextFadeInFinished));
                    break;
            }
        }
        else
        {
            // Immediate
            TextLabel.Modulate = TextLabel.Modulate with { A = 1 };
            TextShadow.Modulate = TextShadow.Modulate with { A = 1 };
            TextFadeInFinished();
        }
    }

    void TextFadeInFinished()
    {
        // Wait to show prompt
        if (_currentEntry.WaitDuration > 0)
        {
            Timing.RunCoroutine(Wait(_currentEntry.WaitDuration, ShowHint));
        }
        else
        {
            //Immediate
            ShowHint();
        }
    }

    void ShowHint()
    {
        InputHint.Show();
        if (HintInDuration > 0)
        {
            Timing.RunCoroutine(FadeHint(HintInDuration, 0, 1, () => {_acceptInput = true;}));
        }
        else
        {
            //Immediate
            _acceptInput = true;
        }
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        if (_acceptInput)
        {
            if (Input.IsActionJustPressed("interact"))
            {
                TonePlayer.Play();
                HideText();
            }
        }
    }

    void HideText()
    {
        _acceptInput = false;
        
        if (_currentEntry.OutDuration > 0)
        {
            Timing.RunCoroutine(FadeText(_currentEntry.OutDuration, 1, 0, () => { }));
            Timing.RunCoroutine(FadeHint(_currentEntry.OutDuration, 1, 0, EmitSignalEntryFinished));
        }
        else
        {
            // Immediate
            TextLabel.Modulate = TextLabel.Modulate with { A = 0 };
            InputHint.Modulate = InputHint.Modulate with { A = 0 };
            EmitSignalEntryFinished();
        }
    }

    IEnumerator<double> FadeText(double duration, float opacityStart, float opacityEnd, Action endCallback)
    {
        double currentTime = 0;

        while (currentTime < duration)
        {
            float weight = (float)(currentTime / duration);
            TextLabel.Modulate = TextLabel.Modulate with { A = float.Lerp(opacityStart, opacityEnd, weight) };
            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
        }

        TextLabel.Modulate = TextLabel.Modulate with { A = opacityEnd };
        endCallback.Invoke();
    }
    IEnumerator<double> TypeText(double duration, float ratioStart, float ratioEnd, Action endCallback)
    {
        double currentTime = 0;

        while (currentTime < duration)
        {
            float weight = (float)(currentTime / duration);
            float shadowWeight = float.Clamp((float)(currentTime / ShadowInDuration), 0, 1);
            TextLabel.VisibleRatio = float.Lerp(ratioStart, ratioEnd, weight);
            TextShadow.Modulate = TextShadow.Modulate with { A = shadowWeight };
            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
        }

        TextLabel.VisibleRatio = ratioEnd;
        endCallback.Invoke();
    }
    
    
    IEnumerator<double> Wait(double time, Action action)
    {
        yield return Timing.WaitForSeconds(time);
        action.Invoke();
    }
    
    IEnumerator<double> FadeHint(double duration, float opacityStart, float opacityEnd, Action endCallback)
    {
        double currentTime = 0;

        while (currentTime < duration)
        {
            float weight = (float)(currentTime / duration);
            InputHint.Modulate = InputHint.Modulate with { A = float.Lerp(opacityStart, opacityEnd, weight) };
            yield return Timing.WaitForOneFrame;
            currentTime += GetProcessDeltaTime();
        }

        InputHint.Modulate = InputHint.Modulate with { A = opacityEnd };
        endCallback.Invoke();
    }
}