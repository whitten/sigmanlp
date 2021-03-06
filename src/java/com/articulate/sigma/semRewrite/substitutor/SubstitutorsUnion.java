/*
 * Copyright 2014-2015 IPsoft
 *
 * Author: Andrei Holub andrei.holub@ipsoft.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program ; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA  02111-1307 USA
 */
package com.articulate.sigma.semRewrite.substitutor;

import com.google.common.collect.Lists;
import edu.stanford.nlp.ling.CoreLabel;

import java.util.List;
import java.util.Optional;

import static com.articulate.sigma.semRewrite.substitutor.CoreLabelSequence.EMPTY_SEQUENCE;

/** **************************************************************
 * This substitutor helps to group set of other substitutors together.
 * All the search/contains calls will return success results if any of united substitutor can do that.
  */
public class SubstitutorsUnion implements ClauseSubstitutor {

    final List<ClauseSubstitutor> substitutors;

    public SubstitutorsUnion(List<ClauseSubstitutor> substitutors) {
        this.substitutors = substitutors;
    }

    public static ClauseSubstitutor of(ClauseSubstitutor... substitutors) {
        SubstitutorsUnion combinator = new SubstitutorsUnion(
                Lists.newArrayList(substitutors)
        );
        return combinator;
    }

    @Override
    public boolean containsKey(CoreLabel key) {

        return substitutors.stream()
                .anyMatch(substitutor -> substitutor.containsKey(key));
    }

    @Override
    public boolean containsKey(String keyLabel) {

        return substitutors.stream()
                .anyMatch(substitutor -> substitutor.containsKey(keyLabel));
    }

    @Override
    public Optional<CoreLabelSequence> getGroupedByFirstLabel(CoreLabel label) {

        return substitutors.stream()
                .map(substitutor -> substitutor.getGroupedByFirstLabel(label))
                .filter(seq -> seq.isPresent())
                .findFirst()
                .orElse(Optional.empty());
    }

    @Override
    public CoreLabelSequence getGrouped(CoreLabel key) {

        return substitutors.stream()
                .filter(substitutor -> substitutor.containsKey(key))
                .map(substitutor -> substitutor.getGrouped(key))
                .findFirst()
                .orElse(EMPTY_SEQUENCE);
    }

    @Override
    public CoreLabelSequence getGrouped(String keyLabel) {

        return substitutors.stream()
                .filter(substitutor -> substitutor.containsKey(keyLabel))
                .map(substitutor -> substitutor.getGrouped(keyLabel))
                .findFirst()
                .orElse(EMPTY_SEQUENCE);
    }
}
