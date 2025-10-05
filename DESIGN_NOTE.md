# Design Notes

## Memory Management

### Value-based Handle Storage

Audio handles (`Music`, `Sound`, `Wave`, `AudioStream`) are stored as values, not pointers:

```crystal
private def initialize(@handle : LibRaudio::Music)
```

**Rationale:**
- raudio's C API returns structs by value
- Struct contains pointers to actual resources
- Copying struct is cheap (just pointer copies)
- Follows raudio's design philosophy

### Resource Cleanup

Each class provides three ways to release resources:

1. `release` / `close` - Explicit cleanup (recommended)
2. Block form - Automatic cleanup via `ensure`
3. `finalize` - GC fallback (not guaranteed to run promptly)

**Recommendation:** Use explicit `release` or block form for predictable resource cleanup.

### GC Considerations

**Callbacks:** AudioStream callbacks are stored in instance variables to prevent GC:

```crystal
@processors : Array(Proc(Pointer(Void), UInt32, Nil))
@@mixed_processors = [] of Proc(Pointer(Void), UInt32, Nil)
```

**Struct Modification:** When C functions require pointers to modify structs in-place:

```crystal
# C API: void WaveCrop(Wave *wave, ...)
LibRaudio.wave_crop(pointerof(@handle), init_sample, final_sample)
```

For simple field assignment, direct access works:

```crystal
@handle.looping = value
```

## API Design Choices

### Property Accessors

Read-only properties expose struct fields directly:

```crystal
def frame_count : UInt32
  @handle.frame_count
end
```

### Looping Behavior

The `Music#looping=` property is synchronized when `play` is called. To change looping for already-playing music, stop and restart it.

## raudio Coverage

All 61 raudio C functions are bound with high-level Crystal wrappers.
