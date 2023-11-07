//
//  ManualSpline.swift
//
//  Created by Nicky Taylor on 11/5/23.
//

import Foundation

class ManualSpline {
    
    private(set) var capacity = 0
    private(set) var count = 0
    private(set) var maxPos = Float(0.0)
    private(set) var closed = false
    
    private var _x = [Float]()
    private var _y = [Float]()
    private var manualTan = [Bool]()
    private var coefXB = [Float]()
    private var coefXC = [Float]()
    private var coefXD = [Float]()
    private var coefYB = [Float]()
    private var coefYC = [Float]()
    private var coefYD = [Float]()
    private(set) var inTanX = [Float]()
    private(set) var inTanY = [Float]()
    private(set) var outTanX = [Float]()
    private(set) var outTanY = [Float]()
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
}

extension ManualSpline {
    func solve(closed: Bool) {
        self.closed = closed
        if count <= 0 {
            maxPos = 0.0
        } else if count == 1 {
            maxPos = 1.0
        } else {
            if closed {
                maxPos = Float(count)
            } else {
                maxPos = Float(count - 1)
            }
            solve(coord: &_x, inTan: &inTanX, outTan: &outTanX, coefB: &coefXB, coefC: &coefXC, coefD: &coefXD)
            solve(coord: &_y, inTan: &inTanY, outTan: &outTanY, coefB: &coefYB, coefC: &coefYC, coefD: &coefYD)
        }
    }
    
   private func solve(coord: inout [Float],
              inTan: inout [Float], outTan: inout [Float],
              coefB: inout [Float], coefC: inout [Float], coefD: inout [Float]) {
       if count == 1 {
           inTan[0] = 0.0
           outTan[0] = 0.0
           return
       }
       var _max = 0
       var _max1 = 0
       var i = 0
       if closed {
           _max = count - 1
           _max1 = _max - 1
           delta[1] = 0.25
           temp[0] = 0.25 * 3.0 * (coord[1] - coord[_max])
           var G = Float(1.0)
           var H = Float(4.0)
           var F = 3.0 * (coord[0] - coord[_max1])
           i = 1
           while i < _max {
               delta[i + 1] = -0.25 * delta[i]
               temp[i] = 0.25 * (3.0 * (coord[i + 1] - coord[i - 1]) - temp[i - 1])
               H = H - G * delta[i]
               F = F - G * delta[i - 1]
               G = -0.25 * G
               i += 1
           }
           H = H - (G + 1.0) * (0.25 + delta[_max])
           temp[_max] = F - (G + 1.0) * temp[_max1]
           if manualTan[_max] == false {
               outTan[_max] = temp[_max] / H
               inTan[_max] = -outTan[_max]
           }
           if manualTan[_max1] == false {
               outTan[_max1] = temp[_max1] - (0.25 + delta[_max]) * outTan[_max]
               inTan[_max1] = -outTan[_max1]
           }
           i = _max - 2
           while i >= 0 {
               if manualTan[i] == false {
                   outTan[i] = temp[i] - 0.25 * outTan[i + 1] - delta[i + 1] * outTan[_max]
                   inTan[i] = -outTan[i]
               }
               i -= 1
           }
           coefB[_max] = outTan[_max]
           coefC[_max] = 3.0 * (coord[0] - coord[_max]) - 2.0 * outTan[_max] + inTan[0]
           coefD[_max] = 2.0 * (coord[_max] - coord[0]) + outTan[_max] - inTan[0]
       } else {
           _max = count - 1
           _max1 = _max - 1
           delta[0] = 3.0 * (coord[1] - coord[0]) * 0.25
           i = 1
           while i < _max {
               delta[i] = (3.0 * (coord[i + 1] - coord[i - 1]) - delta[i - 1]) * 0.25
               i += 1
           }
           delta[_max] = (3.0 * (coord[_max] - coord[_max1]) - delta[_max1]) * 0.25
           if manualTan[_max] == false {
               outTan[_max] = delta[_max]
               inTan[_max] = -outTan[_max]
           }
           i = _max1
           while i >= 0 {
               if manualTan[i] == false {
                   outTan[i] = delta[i] - 0.25 * outTan[i + 1]
                   inTan[i] = -outTan[i]
               }
               i -= 1
           }
       }
       i = 0
       while i < _max {
           coefB[i] = outTan[i]
           coefC[i] = 3.0 * (coord[i + 1] - coord[i]) - 2.0 * outTan[i] + inTan[i + 1]
           coefD[i] = 2.0 * (coord[i] - coord[i + 1]) + outTan[i] - inTan[i + 1]
           i += 1
       }
    }
}
