//
//  ManualSpline.swift
//

import Foundation

class ManualSpline {
    
    private(set) var capacity = 0
    private(set) var count = 0
    private(set) var maxPos = Float(0.0)
    private(set) var maxIndex = 0
    private(set) var closed = false
    
    var _x = [Float]()
    var _y = [Float]()
    
    var manualTan = [Bool]()
    
    private var coefXB = [Float]()
    private var coefXC = [Float]()
    private var coefXD = [Float]()
    private var coefYB = [Float]()
    private var coefYC = [Float]()
    private var coefYD = [Float]()
    
    var inTanX = [Float]()
    var inTanY = [Float]()
    var outTanX = [Float]()
    var outTanY = [Float]()
    
    private var delta = [Float]()
    private var temp = [Float]()
    
    func addControlPoint(_ x: Float, _ y: Float) {
        if count >= capacity {
            reserveCapacity(minimumCapacity: count + (count >> 1) + 1)
        }
        _x[count] = x
        _y[count] = y
        count += 1
    }
    
    // Note: You will need to re-solve() after
    //       ever calling this.
    func remove(at index: Int) {
        
        if index >= 0 && index < count {
            
            var loopIndex = 0
            let ceiling = (count - 1)
            
            loopIndex = index
            while loopIndex < ceiling {
                
                _x[loopIndex] = _x[loopIndex + 1]
                _y[loopIndex] = _y[loopIndex + 1]
                manualTan[loopIndex] = manualTan[loopIndex + 1]
                inTanX[loopIndex] = inTanX[loopIndex + 1]
                inTanY[loopIndex] = inTanY[loopIndex + 1]
                outTanX[loopIndex] = outTanX[loopIndex + 1]
                outTanY[loopIndex] = outTanY[loopIndex + 1]
                loopIndex += 1
            }
            count -= 1
        }
    }
    
    func updateControlPoint(at index: Int, _ x: Float, _ y: Float) {
        if index >= 0 && index < count {
            _x[index] = x
            _y[index] = y
        }
    }
    
    func enableManualControlTan(at index: Int,
                                inTanX: Float, inTanY: Float,
                                outTanX: Float, outTanY: Float) {
        if index >= 0 && index < capacity {
            manualTan[index] = true
            self.inTanX[index] = inTanX
            self.inTanY[index] = inTanY
            self.outTanX[index] = outTanX
            self.outTanY[index] = outTanY
        }
    }
    
    func disableManualControlTan(at index: Int) {
        if index >= 0 && index < capacity {
            manualTan[index] = false
        }
    }
    
    func reserveCapacity(minimumCapacity: Int) {
        if minimumCapacity > capacity {
            
            _x.reserveCapacity(minimumCapacity)
            _y.reserveCapacity(minimumCapacity)
            manualTan.reserveCapacity(minimumCapacity)
            coefXB.reserveCapacity(minimumCapacity)
            coefXC.reserveCapacity(minimumCapacity)
            coefXD.reserveCapacity(minimumCapacity)
            coefYB.reserveCapacity(minimumCapacity)
            coefYC.reserveCapacity(minimumCapacity)
            coefYD.reserveCapacity(minimumCapacity)
            inTanX.reserveCapacity(minimumCapacity)
            inTanY.reserveCapacity(minimumCapacity)
            outTanX.reserveCapacity(minimumCapacity)
            outTanY.reserveCapacity(minimumCapacity)
            delta.reserveCapacity(minimumCapacity)
            temp.reserveCapacity(minimumCapacity)
            
            while _x.count < minimumCapacity { _x.append(0.0) }
            while _y.count < minimumCapacity { _y.append(0.0) }
            while manualTan.count < minimumCapacity { manualTan.append(false) }
            while coefXB.count < minimumCapacity { coefXB.append(0.0) }
            while coefXC.count < minimumCapacity { coefXC.append(0.0) }
            while coefXD.count < minimumCapacity { coefXD.append(0.0) }
            while coefYB.count < minimumCapacity { coefYB.append(0.0) }
            while coefYC.count < minimumCapacity { coefYC.append(0.0) }
            while coefYD.count < minimumCapacity { coefYD.append(0.0) }
            while inTanX.count < minimumCapacity { inTanX.append(0.0) }
            while inTanY.count < minimumCapacity { inTanY.append(0.0) }
            while outTanX.count < minimumCapacity { outTanX.append(0.0) }
            while outTanY.count < minimumCapacity { outTanY.append(0.0) }
            while delta.count < minimumCapacity { delta.append(0.0) }
            while temp.count < minimumCapacity { temp.append(0.0) }
            capacity = minimumCapacity
        }
    }
    
    func removeAll(keepingCapacity: Bool) {
        if keepingCapacity == false {
            _x.removeAll(keepingCapacity: false)
            _y.removeAll(keepingCapacity: false)
            manualTan.removeAll(keepingCapacity: false)
            coefXB.removeAll(keepingCapacity: false)
            coefXC.removeAll(keepingCapacity: false)
            coefXD.removeAll(keepingCapacity: false)
            coefYB.removeAll(keepingCapacity: false)
            coefYC.removeAll(keepingCapacity: false)
            coefYD.removeAll(keepingCapacity: false)
            inTanX.removeAll(keepingCapacity: false)
            inTanY.removeAll(keepingCapacity: false)
            outTanX.removeAll(keepingCapacity: false)
            outTanY.removeAll(keepingCapacity: false)
            delta.removeAll(keepingCapacity: false)
            temp.removeAll(keepingCapacity: false)
            capacity = 0
        }
        count = 0
        maxPos = 0.0
        maxIndex = 0
    }
    
    func getX(_ pos: Float) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _x[0]
        } else {
            if pos >= maxPos {
                if closed {
                    return _x[0]
                } else {
                    return _x[count - 1]
                }
            } else if pos <= 0.0 {
                return _x[0]
            } else {
                let index = Int(pos)
                let percent = pos - Float(index)
                return _x[index] + (((coefXD[index] * percent) + coefXC[index]) * percent + coefXB[index]) * percent
            }
        }
    }
    
    func getX(index: Int, percent: Float) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _x[0]
        } else {
            if index >= maxIndex {
                if closed {
                    return _x[0]
                } else {
                    return _x[count - 1]
                }
            } else if index < 0 {
                return _x[0]
            } else {
                return _x[index] + (((coefXD[index] * percent) + coefXC[index]) * percent + coefXB[index]) * percent
            }
        }
    }
    
    func getY(_ pos: Float) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _y[0]
        } else {
            if pos >= maxPos {
                if closed {
                    return _y[0]
                } else {
                    return _y[count - 1]
                }
            } else if pos <= 0.0 {
                return _y[0]
            } else {
                let index = Int(pos)
                let percent = pos - Float(index)
                return _y[index] + (((coefYD[index] * percent) + coefYC[index]) * percent + coefYB[index]) * percent
            }
        }
    }
    
    func getY(index: Int, percent: Float) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _y[0]
        } else {
            if index >= maxIndex {
                if closed {
                    return _y[0]
                } else {
                    return _y[count - 1]
                }
            } else if index < 0 {
                return _y[0]
            } else {
                return _y[index] + (((coefYD[index] * percent) + coefYC[index]) * percent + coefYB[index]) * percent
            }
        }
    }
    
    func getTanY(_ pos: Float) -> Float {
        if count <= 1 {
            return 0.0
        } else {
            var index = 0
            var percent = Float(0.0)
            if pos >= maxPos {
                if closed {
                    index = 0
                    percent = 0.0
                } else {
                    index = maxIndex
                    percent = 1.0
                }
            } else if pos <= 0.0 {
                index = 0
                percent = 0.0
            } else {
                index = Int(pos)
                percent = pos - Float(index)
            }
            let percentSquared = percent * percent
            return 3.0 * coefYD[index] * percentSquared + 2.0 * coefYC[index] * percent + coefYB[index]
        }
    }
    
    func getTanX(_ pos: Float) -> Float {
        if count <= 1 {
            return 0.0
        } else {
            var index = 0
            var percent = Float(0.0)
            if pos >= maxPos {
                if closed {
                    index = 0
                    percent = 0.0
                } else {
                    index = maxIndex
                    percent = 1.0
                }
            } else if pos <= 0.0 {
                index = 0
                percent = 0.0
            } else {
                index = Int(pos)
                percent = pos - Float(index)
            }
            let percentSquared = percent * percent
            return 3.0 * coefXD[index] * percentSquared + 2.0 * coefXC[index] * percent + coefXB[index]
        }
    }
    
    func getControlX(_ index: Int) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _x[0]
        } else {
            if index <= 0 {
                return _x[0]
            } else if index >= count {
                if closed {
                    return _x[0]
                } else {
                    return _x[count - 1]
                }
            } else {
                return _x[index]
            }
        }
    }
    
    func getControlY(_ index: Int) -> Float {
        if count <= 0 {
            return 0.0
        } else if count == 1 {
            return _y[0]
        } else {
            if index <= 0 {
                return _y[0]
            } else if index >= count {
                if closed {
                    return _y[0]
                } else {
                    return _y[count - 1]
                }
            } else {
                return _y[index]
            }
        }
    }
    
    struct ClosestControlPointResult {
        let index: Int?
        let distance: Float
    }
    
    func closestControlPointIndex(x: Float, y: Float, distance: Float) -> ClosestControlPointResult {
        var index = 0
        var bestDistance = (distance * distance)
        var bestIndex: Int?
        while index < count {
            let controlPointX = _x[index]
            let controlPointY = _y[index]
            let diffX = controlPointX - x
            let diffY = controlPointY - y
            let distance = diffX * diffX + diffY * diffY
            if distance < bestDistance {
                bestIndex = index
                bestDistance = distance
            }
            index += 1
        }
        if bestDistance > Math.epsilon {
            bestDistance = sqrtf(bestDistance)
        }
        return ClosestControlPointResult(index: bestIndex, distance: bestDistance)
    }
    
    func readFromSpline(spline: ManualSpline) {
        removeAll(keepingCapacity: true)
        for index in 0..<spline.count {
            let x = spline._x[index]
            let y = spline._y[index]
            addControlPoint(x, y)
            
            if spline.manualTan[index] {
                manualTan[index] = true
                inTanX[index] = spline.inTanX[index]
                inTanY[index] = spline.inTanY[index]
                outTanX[index] = spline.outTanX[index]
                outTanY[index] = spline.outTanY[index]
            }
        }
    }
    
    func solve(closed: Bool) {
        self.closed = closed
        if count <= 0 {
            maxPos = 0.0
            maxIndex = 0
        } else if count == 1 {
            maxPos = 1.0
            maxIndex = 1
        } else {
            if closed {
                maxPos = Float(count)
                maxIndex = count
            } else {
                maxPos = Float(count - 1)
                maxIndex = (count - 1)
            }
            solveX()
            solveY()
        }
    }
    
    private func solveX() {
        if count == 1 {
            inTanX[0] = 0.0
            outTanX[0] = 0.0
            return
        }
        var _max = 0
        var _max1 = 0
        var i = 0
        if closed {
            _max = count - 1
            _max1 = _max - 1
            delta[1] = 0.25
            temp[0] = 0.25 * 3.0 * (_x[1] - _x[_max])
            var G = Float(1.0)
            var H = Float(4.0)
            var F = 3.0 * (_x[0] - _x[_max1])
            i = 1
            while i < _max {
                delta[i + 1] = -0.25 * delta[i]
                temp[i] = 0.25 * (3.0 * (_x[i + 1] - _x[i - 1]) - temp[i - 1])
                H = H - G * delta[i]
                F = F - G * temp[i - 1]
                G = -0.25 * G
                i += 1
            }
            H = H - (G + 1.0) * (0.25 + delta[_max])
            temp[_max] = F - (G + 1.0) * temp[_max1]
            if manualTan[_max] == false {
                outTanX[_max] = temp[_max] / H
                inTanX[_max] = -outTanX[_max]
            }
            if manualTan[_max1] == false {
                outTanX[_max1] = temp[_max1] - (0.25 + delta[_max]) * -inTanX[_max]
                inTanX[_max1] = -outTanX[_max1]
            }
            
            i = _max - 2
            while i >= 0 {
                if manualTan[i] == false {
                    outTanX[i] = temp[i] - 0.25 * -inTanX[i + 1] - delta[i + 1] * -inTanX[_max]
                    inTanX[i] = -outTanX[i]
                }
                i -= 1
            }
            coefXB[_max] = outTanX[_max]
            coefXC[_max] = 3.0 * (_x[0] - _x[_max]) - 2.0 * outTanX[_max] + inTanX[0]
            coefXD[_max] = 2.0 * (_x[_max] - _x[0]) + outTanX[_max] - inTanX[0]
        } else {
            _max = count - 1
            _max1 = _max - 1
            delta[0] = 3.0 * (_x[1] - _x[0]) * 0.25
            i = 1
            while i < _max {
                delta[i] = (3.0 * (_x[i + 1] - _x[i - 1]) - delta[i - 1]) * 0.25
                i += 1
            }
            delta[_max] = (3.0 * (_x[_max] - _x[_max1]) - delta[_max1]) * 0.25
            if manualTan[_max] == false {
                outTanX[_max] = delta[_max]
                inTanX[_max] = -outTanX[_max]
            }
            i = _max1
            while i >= 0 {
                if manualTan[i] == false {
                    outTanX[i] = delta[i] - 0.25 * -inTanX[i + 1]
                    inTanX[i] = -outTanX[i]
                }
                i -= 1
            }
        }
        
        i = 0
        while i < _max {
            coefXB[i] = outTanX[i]
            coefXC[i] = 3.0 * (_x[i + 1] - _x[i]) - 2.0 * outTanX[i] + inTanX[i + 1]
            coefXD[i] = 2.0 * (_x[i] - _x[i + 1]) + outTanX[i] - inTanX[i + 1]
            i += 1
        }
     }
    
    private func solveY() {
        if count == 1 {
            inTanY[0] = 0.0
            outTanY[0] = 0.0
            return
        }
        var _max = 0
        var _max1 = 0
        var i = 0
        if closed {
            _max = count - 1
            _max1 = _max - 1
            delta[1] = 0.25
            temp[0] = 0.25 * 3.0 * (_y[1] - _y[_max])
            var G = Float(1.0)
            var H = Float(4.0)
            var F = 3.0 * (_y[0] - _y[_max1])
            i = 1
            while i < _max {
                delta[i + 1] = -0.25 * delta[i]
                temp[i] = 0.25 * (3.0 * (_y[i + 1] - _y[i - 1]) - temp[i - 1])
                H = H - G * delta[i]
                F = F - G * temp[i - 1]
                G = -0.25 * G
                i += 1
            }
            H = H - (G + 1.0) * (0.25 + delta[_max])
            temp[_max] = F - (G + 1.0) * temp[_max1]
            if manualTan[_max] == false {
                outTanY[_max] = temp[_max] / H
                inTanY[_max] = -outTanY[_max]
            }
            if manualTan[_max1] == false {
                outTanY[_max1] = temp[_max1] - (0.25 + delta[_max]) * -inTanY[_max]
                inTanY[_max1] = -outTanY[_max1]
            }
            
            i = _max - 2
            while i >= 0 {
                if manualTan[i] == false {
                    outTanY[i] = temp[i] - 0.25 * -inTanY[i + 1] - delta[i + 1] * -inTanY[_max]
                    inTanY[i] = -outTanY[i]
                }
                i -= 1
            }
            coefYB[_max] = outTanY[_max]
            coefYC[_max] = 3.0 * (_y[0] - _y[_max]) - 2.0 * outTanY[_max] + inTanY[0]
            coefYD[_max] = 2.0 * (_y[_max] - _y[0]) + outTanY[_max] - inTanY[0]
        } else {
            _max = count - 1
            _max1 = _max - 1
            delta[0] = 3.0 * (_y[1] - _y[0]) * 0.25
            i = 1
            while i < _max {
                delta[i] = (3.0 * (_y[i + 1] - _y[i - 1]) - delta[i - 1]) * 0.25
                i += 1
            }
            delta[_max] = (3.0 * (_y[_max] - _y[_max1]) - delta[_max1]) * 0.25
            if manualTan[_max] == false {
                outTanY[_max] = delta[_max]
                inTanY[_max] = -outTanY[_max]
            }
            i = _max1
            while i >= 0 {
                if manualTan[i] == false {
                    outTanY[i] = delta[i] - 0.25 * -inTanY[i + 1]
                    inTanY[i] = -outTanY[i]
                }
                i -= 1
            }
        }
        
        i = 0
        while i < _max {
            coefYB[i] = outTanY[i]
            coefYC[i] = 3.0 * (_y[i + 1] - _y[i]) - 2.0 * outTanY[i] + inTanY[i + 1]
            coefYD[i] = 2.0 * (_y[i] - _y[i + 1]) + outTanY[i] - inTanY[i + 1]
            i += 1
        }
     }
}
