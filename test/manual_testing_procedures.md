# Manual Testing Procedures for Julia Point Controller

This document provides comprehensive manual testing procedures for interactive validation of the Julia Point Controller application.

## Prerequisites

1. Ensure Julia is installed and the project environment is activated
2. Run `julia --project=. -e "using Pkg; Pkg.instantiate()"` to install dependencies
3. Verify GLMakie backend is working: `julia --project=. -e "using GLMakie; GLMakie.activate!()"`

## Test Execution

Run the application with: `julia --project=. run_app.jl`

## Manual Test Cases

### Test 1: Basic Application Startup
**Objective**: Verify the application starts correctly and displays the initial interface.

**Steps**:
1. Launch the application
2. Observe the window that opens

**Expected Results**:
- A GLMakie window opens successfully
- A point is visible at the center coordinates (0, 0)
- Coordinate axes are displayed for reference
- Coordinate display shows "Position: (0.0, 0.0)" or similar format
- Window is responsive and can be moved/resized

**Pass Criteria**: ✅ All expected results are observed

---

### Test 2: Single Key Movement
**Objective**: Verify each WASD key moves the point in the correct direction.

**Steps**:
1. Press and hold 'W' key
2. Observe point movement and coordinate display
3. Release 'W' key
4. Repeat for 'A', 'S', and 'D' keys individually

**Expected Results**:
- 'W': Point moves upward (positive Y direction), coordinates update in real-time
- 'A': Point moves leftward (negative X direction), coordinates update in real-time  
- 'S': Point moves downward (negative Y direction), coordinates update in real-time
- 'D': Point moves rightward (positive X direction), coordinates update in real-time
- Point stops immediately when key is released
- Coordinate display updates smoothly during movement
- No flickering or visual artifacts

**Pass Criteria**: ✅ All directions work correctly with smooth coordinate updates

---

### Test 3: Diagonal Movement Combinations
**Objective**: Test simultaneous key presses for diagonal movement.

**Steps**:
1. Press and hold 'W' + 'D' simultaneously
2. Observe diagonal movement (up-right)
3. Release both keys
4. Test all diagonal combinations:
   - 'W' + 'A' (up-left)
   - 'S' + 'D' (down-right)  
   - 'S' + 'A' (down-left)

**Expected Results**:
- Point moves diagonally in the correct direction
- Movement speed appears consistent with single-key movement (not faster)
- Coordinate display shows both X and Y values changing
- Movement is smooth without stuttering
- Point stops when all keys are released

**Pass Criteria**: ✅ All diagonal movements work correctly with proper speed normalization

---

### Test 4: Opposite Key Cancellation
**Objective**: Verify opposite keys cancel each other out.

**Steps**:
1. Press and hold 'W'
2. While holding 'W', press and hold 'S'
3. Observe point behavior
4. Release 'W', keep holding 'S'
5. Observe point behavior
6. Repeat test with 'A' + 'D' combination

**Expected Results**:
- When opposite keys are pressed simultaneously, point stops moving
- Coordinate display stops updating (remains at current position)
- When one opposite key is released, movement resumes in the direction of the remaining key
- No erratic movement or jumping

**Pass Criteria**: ✅ Opposite key cancellation works correctly

---

### Test 5: Rapid Key Press Sequences
**Objective**: Test responsiveness with rapid key changes.

**Steps**:
1. Rapidly press and release different WASD keys in sequence
2. Try rapid combinations like: W→D→S→A→W→D
3. Observe point movement and coordinate updates
4. Test holding multiple keys then releasing them in different orders

**Expected Results**:
- Point responds immediately to each key press/release
- No delayed reactions or missed inputs
- Coordinate display keeps up with rapid changes
- No crashes or freezing
- Movement direction always matches currently pressed keys

**Pass Criteria**: ✅ Application remains responsive during rapid input changes

---

### Test 6: Coordinate Display Accuracy
**Objective**: Verify coordinate display accuracy during various movements.

**Steps**:
1. Move point to various positions using different key combinations
2. Note the coordinate values displayed
3. Move point in a square pattern (W→D→S→A→W)
4. Move point diagonally and observe coordinate precision
5. Test with both small and large movements

**Expected Results**:
- Coordinate display shows precise decimal values
- Values update in real-time during movement
- Diagonal movements show appropriate fractional coordinates
- No coordinate display lag or incorrect values
- Display format is clear and readable

**Pass Criteria**: ✅ Coordinate display is accurate and updates properly

---

### Test 7: Continuous Movement Smoothness
**Objective**: Verify smooth continuous movement while keys are held.

**Steps**:
1. Hold 'W' key for 5+ seconds
2. Observe movement smoothness and consistency
3. Test with diagonal movement (W+D) for 5+ seconds
4. Vary between different keys and combinations
5. Observe coordinate display during continuous movement

**Expected Results**:
- Point moves smoothly without stuttering or jumping
- Movement speed is consistent throughout
- Coordinate display updates smoothly (not in large jumps)
- No performance degradation over time
- Frame rate remains stable

**Pass Criteria**: ✅ Movement is smooth and consistent during extended key holds

---

### Test 8: Application Exit and Cleanup
**Objective**: Test proper application termination.

**Steps**:
1. Press 'Q' key while application is running
2. Observe application behavior
3. Restart application and close window using window controls
4. Test both exit methods multiple times

**Expected Results**:
- 'Q' key causes graceful application exit
- Window closes properly without hanging
- No error messages during shutdown
- Application can be restarted successfully after exit
- No background processes remain after exit

**Pass Criteria**: ✅ Application exits cleanly via both methods

---

### Test 9: Window Focus and Interaction
**Objective**: Test behavior with window focus changes.

**Steps**:
1. Start application and begin moving point with keys
2. Click on another application to remove focus
3. Click back on the Point Controller window
4. Test key responsiveness after regaining focus
5. Try moving/resizing the window while point is moving

**Expected Results**:
- Point stops moving when window loses focus
- Key responsiveness returns when focus is regained
- No stuck keys or continued movement without input
- Window can be moved/resized without issues
- Application remains stable during focus changes

**Pass Criteria**: ✅ Application handles focus changes properly

---

### Test 10: Performance and Resource Usage
**Objective**: Verify application performance under normal use.

**Steps**:
1. Run application for extended period (10+ minutes)
2. Perform various movement patterns continuously
3. Monitor system resource usage (CPU, memory)
4. Test with rapid, complex key combinations
5. Observe for any performance degradation

**Expected Results**:
- CPU usage remains reasonable (not excessive)
- Memory usage is stable (no memory leaks)
- Application remains responsive throughout
- No gradual slowdown or stuttering
- System remains stable

**Pass Criteria**: ✅ Application performs well with stable resource usage

---

## Test Results Summary

| Test Case | Status | Notes |
|-----------|--------|-------|
| Basic Application Startup | ⬜ | |
| Single Key Movement | ⬜ | |
| Diagonal Movement Combinations | ⬜ | |
| Opposite Key Cancellation | ⬜ | |
| Rapid Key Press Sequences | ⬜ | |
| Coordinate Display Accuracy | ⬜ | |
| Continuous Movement Smoothness | ⬜ | |
| Application Exit and Cleanup | ⬜ | |
| Window Focus and Interaction | ⬜ | |
| Performance and Resource Usage | ⬜ | |

## Troubleshooting Common Issues

### Issue: Window doesn't open
- **Solution**: Check GLMakie installation and OpenGL support
- **Command**: `julia --project=. -e "using GLMakie; GLMakie.activate!(); scatter([1,2,3])"`

### Issue: Keys not responding
- **Solution**: Ensure window has focus, check keyboard event setup
- **Debug**: Look for console output showing key press/release events

### Issue: Movement is too fast/slow
- **Solution**: Adjust movement_speed parameter in MovementState constructor
- **Location**: `src/PointController.jl` line with `MovementState(0.1)`

### Issue: Coordinate display not updating
- **Solution**: Check coordinate text observable connection
- **Debug**: Verify `update_coordinate_display!` function is working

### Issue: Application crashes
- **Solution**: Check Julia and GLMakie versions, review error messages
- **Debug**: Run with `julia --project=. --track-allocation=user run_app.jl`

## Validation Checklist

Before considering the application complete, ensure:

- [ ] All 10 test cases pass
- [ ] No crashes or errors during testing
- [ ] Performance is acceptable on target hardware
- [ ] User experience is smooth and intuitive
- [ ] All requirements from the specification are met
- [ ] Code follows Julia best practices
- [ ] Documentation is complete and accurate

## Notes for Testers

1. Test on different operating systems if possible (Windows, macOS, Linux)
2. Try different screen resolutions and DPI settings
3. Test with different Julia versions if applicable
4. Document any unexpected behavior or edge cases discovered
5. Provide feedback on user experience and interface design

## Automated Test Verification

After manual testing, run the automated test suite to verify implementation:

```bash
julia --project=. test/runtests.jl
```

Ensure all automated tests pass before considering the feature complete.